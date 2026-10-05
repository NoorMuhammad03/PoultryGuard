/**
 * PoultryGuard Gemini AI Service
 * Live Google Gemini Vision & Multimodal API Integration
 */

const GEMINI_API_KEY = import.meta.env.VITE_GEMINI_API_KEY || ''

// Fallback candidate models in order of priority
const CANDIDATE_MODELS = ['gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash']

/**
 * Optimize and compress an image file before sending base64 to Gemini API.
 * Resizes max dimension to 1024px and compresses to JPEG 0.8 to reduce latency.
 */
export async function optimizeImage(fileOrUrl, maxWidth = 1024, quality = 0.8) {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.crossOrigin = 'anonymous'

    img.onload = () => {
      let width = img.width
      let height = img.height

      if (width > maxWidth || height > maxWidth) {
        if (width > height) {
          height = Math.round((height * maxWidth) / width)
          width = maxWidth
        } else {
          width = Math.round((width * maxWidth) / height)
          height = maxWidth
        }
      }

      const canvas = document.createElement('canvas')
      canvas.width = width
      canvas.height = height
      const ctx = canvas.getContext('2d')
      ctx.drawImage(img, 0, 0, width, height)

      const dataUrl = canvas.toDataURL('image/jpeg', quality)
      const base64Data = dataUrl.split(',')[1]
      resolve({ base64Data, mimeType: 'image/jpeg', previewUrl: dataUrl })
    }

    img.onerror = (err) => reject(err)

    if (fileOrUrl instanceof File || fileOrUrl instanceof Blob) {
      const reader = new FileReader()
      reader.onload = (e) => {
        img.src = e.target.result
      }
      reader.onerror = reject
      reader.readAsDataURL(fileOrUrl)
    } else if (typeof fileOrUrl === 'string') {
      img.src = fileOrUrl
    } else {
      reject(new Error('Invalid image input'))
    }
  })
}

/**
 * Call Gemini API with timeout and exponential backoff retries.
 */
async function callGeminiWithRetry(endpoint, payload, maxRetries = 2) {
  let lastError = null

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 15000)

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
        signal: controller.signal,
      })
      clearTimeout(timeoutId)

      if (!response.ok) {
        const errText = await response.text()
        const err = new Error(`Gemini HTTP ${response.status}: ${errText}`)
        err.status = response.status
        throw err
      }

      const data = await response.json()
      return data
    } catch (err) {
      clearTimeout(timeoutId)
      lastError = err
      // Do not waste time retrying if quota is exhausted or model is unavailable
      if (err.status === 429 || err.status === 404) {
        break
      }
      if (attempt < maxRetries) {
        // Exponential backoff wait
        await new Promise((res) => setTimeout(res, 800 * Math.pow(2, attempt)))
      }
    }
  }

  throw lastError
}

/**
 * Extract clean JSON string from Gemini response text.
 */
function extractJsonFromText(rawText) {
  if (!rawText) return null
  let cleaned = rawText.trim()
  if (cleaned.startsWith('```json')) {
    cleaned = cleaned.replace(/^```json\s*/, '').replace(/```\s*$/, '')
  } else if (cleaned.startsWith('```')) {
    cleaned = cleaned.replace(/^```\s*/, '').replace(/```\s*$/, '')
  }
  return JSON.parse(cleaned)
}

/**
 * Analyze poultry dropping or bird symptom image using Gemini Vision model.
 */
export async function diagnosePoultryImage(imageFileOrUrl, symptomsText = '', onProgress = null) {
  if (onProgress) onProgress('Optimizing image payload…')
  const { base64Data, mimeType, previewUrl } = await optimizeImage(imageFileOrUrl)

  const systemInstruction = `You are a certified avian veterinarian, board-certified poultry pathologist, and biosecurity officer.
Analyze this poultry image (fecal droppings, cecal droppings, eyes, comb, wattles, or bird plumage) along with any provided symptom context.
Diagnose possible poultry conditions such as Coccidiosis (Eimeria), Newcastle Disease (NDV), Infectious Bursal Disease (Gumboro), Fowl Pox, Salmonellosis, Infectious Bronchitis, or Normal/Healthy.

Return a strictly valid JSON object with the following fields:
{
  "predicted_disease": "Name of primary suspected disease or Normal",
  "confidence_score": 92.5,
  "severity": "critical" | "warning" | "safe",
  "description": "Comprehensive explanation of visible macroscopic pathology and what this indicates",
  "symptoms_detected": ["List of distinct clinical markers observed from image or context"],
  "recommended_steps": ["Immediate veterinary and biosecurity protocol recommendations"]
}`

  const promptText = `Examine this poultry pathology photograph.${
    symptomsText ? ` Observed flock symptoms: ${symptomsText}.` : ''
  } Return the required diagnostic JSON object.`

  const requestBody = {
    contents: [
      {
        parts: [
          { text: systemInstruction + '\n\n' + promptText },
          {
            inlineData: {
              mimeType: mimeType,
              data: base64Data,
            },
          },
        ],
      },
    ],
  }

  let resultData = null
  let lastModelError = null

  // Try candidate models
  for (const model of CANDIDATE_MODELS) {
    if (onProgress) onProgress(`Inferencing via Google Gemini (${model})…`)
    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`

    try {
      const resp = await callGeminiWithRetry(endpoint, requestBody, 1)
      const textOutput = resp?.candidates?.[0]?.content?.parts?.[0]?.text
      if (textOutput) {
        resultData = extractJsonFromText(textOutput)
        break
      }
    } catch (err) {
      console.warn(`Model ${model} failed, trying next candidate:`, err.message)
      lastModelError = err
    }
  }

  if (!resultData) {
    // If all models failed or network offline, provide standard clinical fallback with error notification
    console.error('All live Gemini attempts failed:', lastModelError)
    throw new Error(
      lastModelError?.message || 'Unable to connect to Gemini Vision service. Please check internet connection.'
    )
  }

  // Ensure fields are properly formatted
  return {
    predicted_disease: resultData.predicted_disease || 'Suspected Enteric Infection',
    confidence_score: Math.min(100, Math.max(10, Number(resultData.confidence_score) || 88.5)),
    severity: (resultData.severity || 'warning').toLowerCase(),
    description:
      resultData.description ||
      'Abnormal mucoid droppings observed indicating intestinal irritation and probable parasite infestation.',
    symptoms_detected: Array.isArray(resultData.symptoms_detected)
      ? resultData.symptoms_detected
      : ['Mucosal shedding', 'Discoloration', 'Digestive distress'],
    recommended_steps: Array.isArray(resultData.recommended_steps)
      ? resultData.recommended_steps
      : [
          'Isolate affected flock birds immediately.',
          'Submit fresh fecal samples for laboratory coccidial oocyst flotation count.',
          'Verify drinker water sanitization and replace damp litter.',
        ],
    previewUrl,
    timestamp: new Date().toISOString(),
  }
}

/**
 * Smart Sensor & Edge Control Insights
 * Analyzes live sensor telemetry (temperature, humidity, ammonia) and provides real-time farmer advice.
 */
export async function generateSensorAdvice(telemetry) {
  const { temperature, humidity, ammonia, smoke = 0 } = telemetry

  const prompt = `You are an automated poultry farm climate control specialist.
Analyze these real-time house sensor readings:
- Temperature: ${temperature}°C (Optimal: 21–25°C, Critical > 32°C)
- Relative Humidity: ${humidity}% (Optimal: 50–70%, Critical > 80%)
- Ammonia (NH3): ${ammonia} ppm (Safe < 20 ppm, Alert 20–25 ppm, Toxic > 25 ppm)
- Smoke / Combustible Gas: ${smoke} ppm

Return a strictly valid JSON object:
{
  "overall_status": "safe" | "warning" | "critical",
  "urgency": "Normal Operations" | "Monitor Closely" | "Immediate Action Required",
  "summary": "1-2 sentence executive assessment of environmental conditions",
  "ventilation_action": "Specific instructions for fan speed, curtain drops, or air inlets",
  "temperature_action": "Specific instructions for cooling pads, misters, or brooder heaters",
  "action_checklist": [
    "Step 1 for farm operator",
    "Step 2 for farm operator"
  ]
}`

  const requestBody = {
    contents: [
      {
        parts: [{ text: prompt }],
      },
    ],
  }

  for (const model of CANDIDATE_MODELS) {
    const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`
    try {
      const resp = await callGeminiWithRetry(endpoint, requestBody, 1)
      const textOutput = resp?.candidates?.[0]?.content?.parts?.[0]?.text
      if (textOutput) {
        return extractJsonFromText(textOutput)
      }
    } catch (err) {
      console.warn(`Sensor advice via ${model} failed, trying fallback:`, err.message)
      if (err.status === 429) {
        break
      }
    }
  }

  // Deterministic rule-based fallback if API is unreachable
  const isCritical = temperature > 32 || humidity > 80 || ammonia > 25
  const isWarning = temperature > 29 || humidity > 72 || ammonia > 18

  return {
    overall_status: isCritical ? 'critical' : isWarning ? 'warning' : 'safe',
    urgency: isCritical
      ? 'Immediate Action Required'
      : isWarning
      ? 'Monitor Closely'
      : 'Normal Operations',
    summary: isCritical
      ? `Critical environmental thresholds crossed: Ammonia at ${ammonia} ppm or Temp at ${temperature}°C.`
      : `House conditions are within standard operational tolerances.`,
    ventilation_action:
      ammonia > 20 || humidity > 75
        ? 'Engage tunnel ventilation fans at 100% capacity and open side air inlets.'
        : 'Maintain minimum ventilation cycle of 2 minutes ON, 3 minutes OFF.',
    temperature_action:
      temperature > 30
        ? 'Activate evaporative cooling pad pumps in 1-minute pulse cycles.'
        : 'Heaters/Coolers in standby mode.',
    action_checklist: [
      ammonia > 20 ? 'Inspect litter under drinker lines for moisture leaks' : 'Verify feed and water consumption',
      'Check fan belt tension and air inlet flap opening angle',
      'Log sensor calibration check',
    ],
  }
}

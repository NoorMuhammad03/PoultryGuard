// FarmStatusBadge — PoultryGuard official status pill driven by farm/sensor status.
// Primary Dark Green (#214E34) for Safe / Active
// Soft Sage Green (#E1EDE6) for background accents
// Warning / Alert Red (#D9534F) for Critical

const STATUS_STYLES = {
  safe: {
    label: 'Safe',
    bg: 'bg-[#E1EDE6]',
    text: 'text-[#214E34]',
    border: 'border-[#214E34]/30',
    dot: 'bg-[#214E34]',
  },
  active: {
    label: 'Active',
    bg: 'bg-[#E1EDE6]',
    text: 'text-[#214E34]',
    border: 'border-[#214E34]/30',
    dot: 'bg-[#214E34]',
  },
  warning: {
    label: 'Warning',
    bg: 'bg-amber-50',
    text: 'text-amber-800',
    border: 'border-amber-200',
    dot: 'bg-amber-500',
  },
  critical: {
    label: 'Critical',
    bg: 'bg-[#FDF2F2]',
    text: 'text-[#D9534F]',
    border: 'border-[#D9534F]/30',
    dot: 'bg-[#D9534F]',
  },
  unknown: {
    label: 'Unknown',
    bg: 'bg-[#F4F8F5]',
    text: 'text-[#666666]',
    border: 'border-[#E1EDE6]',
    dot: 'bg-[#666666]',
  },
}

export default function FarmStatusBadge({ status, showDot = true, className = '' }) {
  const value = typeof status === 'string' ? status.toLowerCase() : status?.status?.toLowerCase()
  const normalized = STATUS_STYLES[value] ? value : 'unknown'
  const style = STATUS_STYLES[normalized]

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-0.5 text-xs font-semibold tracking-wide ${style.bg} ${style.text} ${style.border} ${className}`}
    >
      {showDot && <span className={`h-1.5 w-1.5 rounded-full ${style.dot}`} />}
      {style.label}
    </span>
  )
}

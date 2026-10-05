import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import axiosClient from '../api/axiosClient'
import { CheckCircle, XCircle, AlertTriangle, Loader2, ShieldCheck } from 'lucide-react'

export default function VeterinaryVerification() {
  const queryClient = useQueryClient()

  // Fetch pending vets (not verified)
  const { data: users = [], isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await axiosClient.get('/admin/users')
      return res.data
    },
    staleTime: 5 * 60_000,
  })

  const pendingVets = users.filter((u) => u.role === 'vet' && !u.is_verified)

  // Verify mutation
  const verifyMutation = useMutation({
    mutationFn: async ({ userId, isVerified }) => {
      await axiosClient.patch(`/admin/users/${userId}/verify`, {
        is_verified: isVerified,
      })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })

  // Handle approve
  const handleApprove = async (vet) => {
    if (!window.confirm(`Verify ${vet.name} as a licensed vet?`)) return
    verifyMutation.mutate({ userId: vet.id, isVerified: true })
  }

  // Handle reject
  const handleReject = async (vet) => {
    if (!window.confirm(`Reject ${vet.name}'s vet registration?`)) return
    verifyMutation.mutate({ userId: vet.id, isVerified: false })
  }

  if (isLoading) {
    return (
      <div className="flex min-h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-slate-400" />
        <p className="ml-3 text-sm text-slate-500">Loading vet list...</p>
      </div>
    )
  }

  if (pendingVets.length === 0) {
    return (
      <div className="rounded-lg border border-slate-200 bg-white p-12 text-center">
        <ShieldCheck className="mx-auto h-12 w-12 text-green-500" />
        <h2 className="mt-3 text-lg font-semibold text-slate-800">No pending verifications</h2>
        <p className="mt-1 text-sm text-slate-500">
          All vet registrations have been reviewed.
        </p>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-5xl">
      <div className="mb-6">
        <h1 className="mb-2 text-2xl font-bold text-slate-800">Veterinary Verification</h1>
        <p className="text-sm text-slate-500">
          Review and approve or reject vet registration requests
        </p>
      </div>

      <div className="space-y-4">
        {pendingVets.map((vet) => (
          <VetCard
            key={vet.id}
            vet={vet}
            onApprove={handleApprove}
            onReject={handleReject}
            isVerifying={verifyMutation.isPending}
          />
        ))}
      </div>
    </div>
  )
}

function VetCard({ vet, onApprove, onReject, isVerifying }) {
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-6 shadow-sm">
      <div className="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
        <div className="flex flex-col gap-1">
          <div className="flex items-center gap-2">
            <h2 className="text-lg font-semibold text-slate-800">{vet.name}</h2>
            <span className="inline-flex items-center rounded-full border border-slate-200 bg-slate-50 px-2 py-0.5 text-xs text-slate-600">
              {vet.id}
            </span>
          </div>
          <p className="text-sm text-slate-600">{vet.email}</p>
          <p className="text-xs text-slate-400">{vet.firebase_uid}</p>
        </div>

        <div className="flex gap-2 text-xs">
          <span className="inline-flex items-center rounded-full border border-yellow-200 bg-yellow-50 px-2 py-1 text-yellow-700">
            ⏳ Pending review
          </span>
        </div>
      </div>

      {vet.notes && (
        <div className="mt-3 rounded border border-slate-200 bg-slate-50 px-3 py-2 text-sm text-slate-600">
          {vet.notes}
        </div>
      )}

      <div className="mt-4 flex gap-2">
        <button
          type="button"
          onClick={() => onApprove(vet)}
          disabled={isVerifying}
          className="inline-flex items-center gap-1.5 rounded-xl bg-[#214E34] px-4 py-2 text-sm font-semibold text-[#FFFFFF] hover:bg-[#193D29] disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          <CheckCircle className="h-4 w-4" />
          Approve Verification
        </button>

        <button
          type="button"
          onClick={() => onReject(vet)}
          disabled={isVerifying}
          className="inline-flex items-center gap-1.5 rounded-xl border border-[#D9534F] bg-[#FFFFFF] px-4 py-2 text-sm font-semibold text-[#D9534F] hover:bg-[#FDF2F2] disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          <XCircle className="h-4 w-4" />
          Reject
        </button>
      </div>
    </div>
  )
}

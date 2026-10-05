import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import axiosClient from '../api/axiosClient'
import { User, Search, Power, ShieldCheck, Loader2, AlertCircle, CheckCircle, XCircle, MoreHorizontal } from 'lucide-react'
import { useToast } from '../hooks/useToast'
import { LoadingSkeleton, EmptyState, ErrorState } from '../components/LoadingSkeleton'

export default function UserManagement() {
  const queryClient = useQueryClient()
  const toast = useToast()
  const [searchTerm, setSearchTerm] = useState('')
  const [filter, setFilter] = useState('all')
  const [currentPage, setCurrentPage] = useState(1)
  const [deactivateUserId, setDeactivateUserId] = useState(null)
  const [confirmDeactivate, setConfirmDeactivate] = useState(false)

  // Fetch all users
  const { data: users = [], isLoading } = useQuery({
    queryKey: ['users', filter, searchTerm],
    queryFn: async () => {
      const params = new URLSearchParams()
      if (filter !== 'all') params.append('role', filter)
      if (searchTerm) params.append('search', searchTerm)
      const res = await axiosClient.get(`/admin/users?${params}`)
      return res.data
    },
    staleTime: 5 * 60_000,
  })

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

  // Deactivate mutation
  const deactivateMutation = useMutation({
    mutationFn: async ({ userId, isActive }) => {
      await axiosClient.patch(`/admin/users/${userId}/deactivate`, {
        is_active: isActive,
      })
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
      setConfirmDeactivate(false)
      setDeactivateUserId(null)
    },
  })

  // Handle mutation errors
  verifyMutation.onError = (err) => {
    toast.addToast(`Failed to update vet status: ${err.message}`, 'error')
  }
  deactivateMutation.onError = (err) => {
    toast.addToast(`Failed to update user status: ${err.message}`, 'error')
  }

  // Handle confirm deactivation
  const handleConfirmDeactivate = () => {
    if (deactivateUserId) {
      deactivateMutation.mutate({
        userId: deactivateUserId,
        isActive: false,
      })
    }
  }

  // Handle reactivate
  const handleReactivate = (userId) => {
    if (!window.confirm(`Reactivate this user's account?`)) return
    deactivateMutation.mutate({
      userId,
      isActive: true,
    })
  }

  // Pagination
  const ITEMS_PER_PAGE = 10
  const filteredUsers = users.filter((u) => {
    const matchesSearch =
      u.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      u.email.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesFilter = filter === 'all' || u.role === filter
    return matchesSearch && matchesFilter
  })

  const totalPages = Math.ceil(filteredUsers.length / ITEMS_PER_PAGE)
  const startIndex = (currentPage - 1) * ITEMS_PER_PAGE
  const paginatedUsers = filteredUsers.slice(startIndex, startIndex + ITEMS_PER_PAGE)

  return (
    <div className="mx-auto max-w-6xl">
      <div className="mb-6">
        <h1 className="mb-2 text-2xl font-bold text-slate-800">User Management</h1>
        <p className="text-sm text-slate-500">
          View, approve, and deactivate all user accounts
        </p>
      </div>

      {/* Search and filters */}
      <div className="mb-6 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search by name or email..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value)
              setCurrentPage(1)
            }}
            className="w-full rounded-lg border border-slate-300 pl-10 pr-4 py-2 text-sm focus:border-slate-500 focus:outline-none focus:ring-2 focus:ring-slate-200"
          />
        </div>

        <div className="flex gap-2">
          <button
            type="button"
            onClick={() => {
              setFilter('all')
              setCurrentPage(1)
            }}
            className={`rounded-full border px-3 py-1.5 text-xs font-medium ${
              filter === 'all'
                ? 'bg-slate-800 text-white'
                : 'bg-white text-slate-700 hover:bg-slate-50'
            }`}
          >
            All ({users.length})
          </button>
          <button
            type="button"
            onClick={() => {
              setFilter('farmer')
              setCurrentPage(1)
            }}
            className={`rounded-full border px-3 py-1.5 text-xs font-medium ${
              filter === 'farmer'
                ? 'bg-slate-800 text-white'
                : 'bg-white text-slate-700 hover:bg-slate-50'
            }`}
          >
            Farmers ({users.filter((u) => u.role === 'farmer').length})
          </button>
          <button
            type="button"
            onClick={() => {
              setFilter('vet')
              setCurrentPage(1)
            }}
            className={`rounded-full border px-3 py-1.5 text-xs font-medium ${
              filter === 'vet'
                ? 'bg-slate-800 text-white'
                : 'bg-white text-slate-700 hover:bg-slate-50'
            }`}
          >
            Vets ({users.filter((u) => u.role === 'vet').length})
          </button>
        </div>
      </div>

      {isLoading ? (
        <LoadingSkeleton />
      ) : paginatedUsers.length === 0 ? (
        <EmptyState
          title="No users found"
          description={
            searchTerm || filter !== 'all'
              ? 'No users match your search or filter criteria.'
              : 'No users registered yet.'
          }
          icon={User}
        />
      ) : (
        <div className="rounded-lg border border-slate-200 bg-white overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead className="border-b border-slate-200 bg-slate-50">
                <tr>
                  <th className="px-4 py-3 text-xs font-semibold text-slate-600">
                    User
                  </th>
                  <th className="px-4 py-3 text-xs font-semibold text-slate-600">
                    Role
                  </th>
                  <th className="px-4 py-3 text-xs font-semibold text-slate-600">
                    Status
                  </th>
                  <th className="px-4 py-3 text-xs font-semibold text-slate-600">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {paginatedUsers.map((user) => (
                  <UserRow
                    key={user.id}
                    user={user}
                    onVerify={(isVerified) =>
                      verifyMutation.mutate({ userId: user.id, isVerified })
                    }
                    onDeactivate={() => setDeactivateUserId(user.id)}
                    onReactivate={handleReactivate}
                    isVerifying={verifyMutation.isPending}
                    isDeactivating={deactivateMutation.isPending}
                  />
                ))}
              </tbody>
            </table>
          </div>

          {/* Pagination controls */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between border-t border-slate-200 px-4 py-3">
              <div className="text-xs text-slate-500">
                Showing {startIndex + 1}-{Math.min(startIndex + ITEMS_PER_PAGE, filteredUsers.length)} of {filteredUsers.length} users
              </div>
              <div className="flex gap-1">
                <button
                  type="button"
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                  className="rounded-md border px-2 py-1 text-xs font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Previous
                </button>
                <div className="flex gap-1">
                  {[...Array(totalPages)].map((_, i) => (
                    <button
                      key={i + 1}
                      type="button"
                      onClick={() => setCurrentPage(i + 1)}
                      className={`rounded-md px-2 py-1 text-xs font-medium ${
                        currentPage === i + 1
                          ? 'bg-slate-800 text-white'
                          : 'bg-white text-slate-700 hover:bg-slate-50'
                      }`}
                    >
                      {i + 1}
                    </button>
                  ))}
                </div>
                <button
                  type="button"
                  onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                  className="rounded-md border px-2 py-1 text-xs font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Deactivate confirmation dialog */}
      {confirmDeactivate && deactivateUserId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4">
          <div className="rounded-lg border border-slate-200 bg-white p-6 shadow-lg max-w-sm w-full">
            <AlertCircle className="mx-auto h-10 w-10 text-red-600" />
            <h3 className="mt-3 text-lg font-semibold text-slate-800">
              Deactivate User
            </h3>
            <p className="mt-2 text-sm text-slate-600">
              Are you sure you want to deactivate this user's account? They will no longer be able to sign in.
            </p>
            <div className="mt-4 flex gap-2 justify-end">
              <button
                type="button"
                onClick={() => {
                  setConfirmDeactivate(false)
                  setDeactivateUserId(null)
                }}
                className="rounded-md border px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleConfirmDeactivate}
                disabled={deactivateMutation.isPending}
                className="rounded-md bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700 disabled:opacity-50"
              >
                {deactivateMutation.isPending ? 'Deactivating...' : 'Deactivate'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function UserRow({ user, onVerify, onDeactivate, onReactivate, isVerifying, isDeactivating }) {
  const getRoleBadgeClass = (role) => {
    switch (role) {
      case 'admin':
        return 'bg-purple-100 text-purple-700'
      case 'vet':
        return 'bg-blue-100 text-blue-700'
      case 'farmer':
        return 'bg-green-100 text-green-700'
      default:
        return 'bg-slate-100 text-slate-700'
    }
  }

  const getStatusBadge = () => {
    if (!user.is_active) {
      return (
        <span className="inline-flex items-center gap-1 rounded-full border border-red-200 bg-red-50 px-2 py-0.5 text-xs font-medium text-red-700">
          <XCircle className="h-3 w-3" />
          Inactive
        </span>
      )
    }
    if (user.role === 'vet' && !user.is_verified) {
      return (
        <span className="inline-flex items-center gap-1 rounded-full border border-amber-200 bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-700">
          <AlertCircle className="h-3 w-3" />
          Pending
        </span>
      )
    }
    return (
      <span className="inline-flex items-center gap-1 rounded-full border border-green-200 bg-green-50 px-2 py-0.5 text-xs font-medium text-green-700">
        <CheckCircle className="h-3 w-3" />
        Active
      </span>
    )
  }

  return (
    <tr className="hover:bg-slate-50">
      <td className="px-4 py-3">
        <div className="flex flex-col gap-0.5">
          <div className="flex items-center gap-2">
            <h3 className="text-sm font-medium text-slate-800">{user.name}</h3>
            <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${getRoleBadgeClass(user.role)}`}>
              {user.role}
            </span>
          </div>
          <p className="text-xs text-slate-500">{user.email}</p>
          <p className="text-xs text-slate-400">{user.firebase_uid}</p>
        </div>
      </td>
      <td className="px-4 py-3">
        <span className="text-xs text-slate-600">{user.role.charAt(0).toUpperCase() + user.role.slice(1)}</span>
      </td>
      <td className="px-4 py-3">{getStatusBadge()}</td>
      <td className="px-4 py-3">
        <div className="flex gap-2">
          {user.role === 'vet' && !user.is_verified && (
            <button
              type="button"
              onClick={() => onVerify(true)}
              disabled={isVerifying}
              className="rounded-md border border-green-300 bg-white px-3 py-1.5 text-xs font-medium text-green-700 hover:bg-green-50 disabled:opacity-50"
            >
              {isVerifying ? 'Verifying...' : 'Verify'}
            </button>
          )}
          {user.is_active ? (
            <button
              type="button"
              onClick={onDeactivate}
              disabled={isDeactivating}
              className="rounded-md border border-red-300 bg-white px-3 py-1.5 text-xs font-medium text-red-700 hover:bg-red-50 disabled:opacity-50"
            >
              <Power className="h-3 w-3" />
            </button>
          ) : (
            <button
              type="button"
              onClick={() => onReactivate(user.id)}
              disabled={isDeactivating}
              className="rounded-md border border-green-300 bg-white px-3 py-1.5 text-xs font-medium text-green-700 hover:bg-green-50 disabled:opacity-50"
            >
              <ShieldCheck className="h-3 w-3" />
            </button>
          )}
        </div>
      </td>
    </tr>
  )
}

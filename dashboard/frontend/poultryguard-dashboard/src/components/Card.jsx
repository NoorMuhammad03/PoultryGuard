/**
 * PoultryGuard Standard Card Component
 * Base background #FFFFFF with #E1EDE6 borders and optional sage tint.
 */
export function Card({
  children,
  className = '',
  header,
  footer,
  variant = 'default',
  ...props
}) {
  const variantStyles = {
    default: 'bg-[#FFFFFF] border-[#E1EDE6]',
    sage: 'bg-[#E1EDE6]/40 border-[#C8DDD1]',
    highlight: 'bg-[#FFFFFF] border-[#214E34]/30 shadow-sm',
    alert: 'bg-[#FDF2F2] border-[#D9534F]/30',
  }

  return (
    <div
      className={`rounded-2xl border p-5 sm:p-6 transition-all ${variantStyles[variant] || variantStyles.default} ${className}`}
      {...props}
    >
      {header && <div className="mb-4 text-[#222222]">{header}</div>}
      <div className="text-[#222222]">{children}</div>
      {footer && <div className="mt-4 pt-4 border-t border-[#E1EDE6] text-[#222222]">{footer}</div>}
    </div>
  )
}

export default Card
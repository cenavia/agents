import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useCancelOrder } from '../mutations';

const cancelSchema = z.object({
  reason: z.string().min(10, 'Please provide at least 10 characters').max(500),
});

type CancelFormData = z.infer<typeof cancelSchema>;

interface CancelOrderFormProps {
  orderId: string;
  onSuccess: () => void;
  onCancel: () => void;
}

export function CancelOrderForm({ orderId, onSuccess, onCancel }: CancelOrderFormProps) {
  const cancelOrder = useCancelOrder();

  const {
    register,
    handleSubmit,
    setError,
    formState: { errors, isSubmitting },
  } = useForm<CancelFormData>({
    resolver: zodResolver(cancelSchema),
  });

  async function onSubmit(data: CancelFormData) {
    try {
      await cancelOrder.mutateAsync({ id: orderId, dto: data });
      onSuccess();
    } catch {
      setError('root', { message: 'Failed to cancel order. Please try again.' });
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <label htmlFor="reason">Reason for cancellation</label>
      <textarea
        id="reason"
        rows={4}
        placeholder="Describe why you want to cancel this order…"
        aria-invalid={!!errors.reason}
        aria-describedby={errors.reason ? 'reason-error' : undefined}
        {...register('reason')}
      />
      {errors.reason && (
        <p id="reason-error" role="alert">{errors.reason.message}</p>
      )}

      {errors.root && (
        <p role="alert">{errors.root.message}</p>
      )}

      <div>
        <button type="button" onClick={onCancel}>Go back</button>
        <button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Cancelling…' : 'Confirm cancellation'}
        </button>
      </div>
    </form>
  );
}

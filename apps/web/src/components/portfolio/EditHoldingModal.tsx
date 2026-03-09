"use client";
import { useState } from "react";
import { Modal } from "@/components/ui/Modal";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { api, type HoldingData } from "@/lib/api-client";

export function EditHoldingModal({
  isOpen,
  onClose,
  holding,
  onSaved,
}: {
  isOpen: boolean;
  onClose: () => void;
  holding: HoldingData;
  onSaved: () => void;
}) {
  const [shares, setShares] = useState(holding.shares.toString());
  const [avgBuyPrice, setAvgBuyPrice] = useState(holding.avgBuyPrice.toString());
  const [manualPrice, setManualPrice] = useState(
    holding.manualPrice != null ? holding.manualPrice.toString() : "",
  );
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const parsedManual = manualPrice.trim() === "" ? null : parseFloat(manualPrice);
      await api.holdings.update(holding.id, {
        shares: parseFloat(shares) || 0,
        avgBuyPrice: parseFloat(avgBuyPrice) || 0,
        manualPrice: parsedManual,
      });
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update");
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete() {
    if (!confirm(`Remove ${holding.symbol} from portfolio?`)) return;
    setLoading(true);
    try {
      await api.holdings.delete(holding.id);
      onSaved();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to delete");
    } finally {
      setLoading(false);
    }
  }

  return (
    <Modal isOpen={isOpen} onClose={onClose} title={`Edit ${holding.symbol}`}>
      <div className="mb-4">
        <p className="dark:text-slate-400 text-slate-500 text-sm">
          {holding.name}
          {holding.platform && (
            <span className="ml-2 px-1.5 py-0.5 dark:bg-slate-700 bg-slate-200 rounded text-xs dark:text-slate-300 text-slate-600">
              {holding.platform}
            </span>
          )}
        </p>
        {holding.currentPrice > 0 && (
          <p className="text-lg font-semibold mt-1">
            Current: ${holding.currentPrice.toFixed(2)}
            {holding.manualPrice != null && (
              <span className="text-xs ml-2 text-amber-400">(manual)</span>
            )}
            <span className={`text-sm ml-2 ${holding.profitLoss >= 0 ? "text-emerald-400" : "text-red-400"}`}>
              P/L: {holding.profitLoss >= 0 ? "+" : ""}${holding.profitLoss.toFixed(2)}
            </span>
          </p>
        )}
      </div>

      <form onSubmit={handleSave} className="space-y-4">
        <Input
          label="Number of Shares"
          type="number"
          step="any"
          min="0"
          value={shares}
          onChange={(e) => setShares(e.target.value)}
        />

        <Input
          label={`Average Buy Price (${holding.currency})`}
          type="number"
          step="any"
          min="0"
          value={avgBuyPrice}
          onChange={(e) => setAvgBuyPrice(e.target.value)}
        />

        <div>
          <Input
            label={`Current Price — Manual Override (${holding.currency})`}
            type="number"
            step="any"
            min="0"
            value={manualPrice}
            onChange={(e) => setManualPrice(e.target.value)}
            placeholder="Leave empty for live API price"
          />
          <p className="text-xs dark:text-slate-500 text-slate-400 mt-1">
            Set a manual price for stocks not supported by the free API (e.g. CRWV, GRAB, C6L.SI).
            Leave empty to use the live API price.
          </p>
        </div>

        {error && <p className="text-red-400 text-sm">{error}</p>}

        <div className="flex justify-between">
          <Button variant="danger" type="button" onClick={handleDelete} disabled={loading}>
            Remove
          </Button>
          <div className="flex gap-2">
            <Button variant="secondary" type="button" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? "Saving..." : "Save"}
            </Button>
          </div>
        </div>
      </form>
    </Modal>
  );
}

"use client";
import { useState } from "react";
import { Modal } from "@/components/ui/Modal";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { api } from "@/lib/api-client";

const PLATFORM_OPTIONS = ["Moomoo", "Tiger", "IBKR", "OKX", "CoinHako"];

export function AddHoldingModal({
  isOpen,
  onClose,
  portfolioId,
  onAdded,
}: {
  isOpen: boolean;
  onClose: () => void;
  portfolioId: string;
  onAdded: () => void;
}) {
  const [symbol, setSymbol] = useState("");
  const [name, setName] = useState("");
  const [assetType, setAssetType] = useState<"us_stock" | "sg_stock" | "crypto">("us_stock");
  const [shares, setShares] = useState("");
  const [avgBuyPrice, setAvgBuyPrice] = useState("");
  const [platform, setPlatform] = useState("");
  const [customPlatform, setCustomPlatform] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const effectivePlatform = platform === "__custom" ? customPlatform : platform;

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      await api.holdings.create(portfolioId, {
        symbol: symbol.toUpperCase(),
        name,
        assetType,
        shares: parseFloat(shares) || 0,
        avgBuyPrice: parseFloat(avgBuyPrice) || 0,
        currency: assetType === "sg_stock" ? "SGD" : "USD",
        platform: effectivePlatform,
      });
      onAdded();
      // Reset form
      setSymbol("");
      setName("");
      setShares("");
      setAvgBuyPrice("");
      setPlatform("");
      setCustomPlatform("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to add holding");
    } finally {
      setLoading(false);
    }
  }

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="Add Holding">
      <form onSubmit={handleSubmit} className="space-y-4">
        <div className="flex gap-2">
          {(["us_stock", "sg_stock", "crypto"] as const).map((type) => (
            <button
              key={type}
              type="button"
              onClick={() => setAssetType(type)}
              className={`px-3 py-1.5 rounded-lg text-sm ${
                assetType === type
                  ? "bg-blue-600 text-white"
                  : "dark:bg-slate-800 bg-slate-100 dark:text-slate-400 text-slate-600"
              }`}
            >
              {type === "us_stock" ? "US Stock" : type === "sg_stock" ? "SG Stock" : "Crypto"}
            </button>
          ))}
        </div>

        <Input
          label="Symbol"
          placeholder={assetType === "crypto" ? "bitcoin" : "NVDA"}
          value={symbol}
          onChange={(e) => setSymbol(e.target.value)}
          required
        />

        <Input
          label="Name"
          placeholder="NVIDIA Corp"
          value={name}
          onChange={(e) => setName(e.target.value)}
          required
        />

        <div className="grid grid-cols-2 gap-3">
          <Input
            label="Shares"
            type="number"
            step="any"
            min="0"
            placeholder="10"
            value={shares}
            onChange={(e) => setShares(e.target.value)}
          />
          <Input
            label="Avg Buy Price"
            type="number"
            step="any"
            min="0"
            placeholder="120.50"
            value={avgBuyPrice}
            onChange={(e) => setAvgBuyPrice(e.target.value)}
          />
        </div>

        <div>
          <label className="block text-sm dark:text-slate-400 text-slate-600 mb-1">Platform / App</label>
          <select
            value={platform}
            onChange={(e) => setPlatform(e.target.value)}
            className="w-full dark:bg-slate-800 bg-white border dark:border-slate-700 border-slate-300 rounded-lg px-3 py-2 dark:text-white text-slate-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
          >
            <option value="">-- Select Platform --</option>
            {PLATFORM_OPTIONS.map((p) => (
              <option key={p} value={p}>{p}</option>
            ))}
            <option value="__custom">Other...</option>
          </select>
        </div>

        {platform === "__custom" && (
          <Input
            label="Custom Platform Name"
            placeholder="Enter platform name"
            value={customPlatform}
            onChange={(e) => setCustomPlatform(e.target.value)}
          />
        )}

        {error && <p className="text-red-400 text-sm">{error}</p>}

        <div className="flex gap-2 justify-end">
          <Button variant="secondary" type="button" onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" disabled={loading || !symbol || !name}>
            {loading ? "Adding..." : "Add Holding"}
          </Button>
        </div>
      </form>
    </Modal>
  );
}

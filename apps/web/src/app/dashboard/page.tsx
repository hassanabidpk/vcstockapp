"use client";
import { useState } from "react";
import { usePortfolioContext } from "@/context/PortfolioContext";
import { usePortfolio, usePortfolioHistory } from "@/hooks/usePortfolio";
import { PortfolioSummary } from "@/components/portfolio/PortfolioSummary";
import { HoldingsTable } from "@/components/portfolio/HoldingsTable";
import { AddHoldingModal } from "@/components/portfolio/AddHoldingModal";
import { PortfolioPLChart } from "@/components/charts/PortfolioPLChart";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Skeleton } from "@/components/ui/Skeleton";
import { ASSET_TYPE_LABELS } from "@/lib/constants";

export default function DashboardPage() {
  const { activePortfolio, isLoading: loadingPortfolios } = usePortfolioContext();
  const { portfolio, isLoading, refresh } = usePortfolio(activePortfolio?.id || null);
  const { history } = usePortfolioHistory(activePortfolio?.id || null);
  const [showAddModal, setShowAddModal] = useState(false);

  if (loadingPortfolios || isLoading) {
    return (
      <div className="p-4 space-y-4">
        <div className="flex items-start justify-between">
          <Skeleton className="h-20 w-48" />
          <Skeleton className="h-16 w-32" />
        </div>
        <Skeleton className="h-48" />
        <Skeleton className="h-64" />
      </div>
    );
  }

  if (!portfolio) {
    return (
      <div className="p-4">
        <Card className="text-center py-12">
          <p className="text-slate-400">Select a portfolio to view</p>
        </Card>
      </div>
    );
  }

  const assetTypes = ["us_stock", "sg_stock", "crypto"] as const;

  return (
    <div className="p-4">
      {/* Summary Cards */}
      <PortfolioSummary summary={portfolio.summary} usdToSgd={portfolio.usdToSgd} />

      {/* P/L Trend Chart */}
      <Card className="mb-6">
        <h3 className="font-semibold mb-3">Portfolio P/L Trend</h3>
        <PortfolioPLChart data={history} />
      </Card>

      {/* Holdings by Asset Type */}
      {assetTypes.map((type) => {
        const holdings = portfolio.holdings.filter((h) => h.assetType === type);
        if (holdings.length === 0) return null;

        return (
          <HoldingsTable
            key={type}
            title={ASSET_TYPE_LABELS[type] || type}
            holdings={holdings}
            portfolioTotalValue={portfolio.summary.totalValue}
            onRefresh={refresh}
          />
        );
      })}

      {/* Add Holding Button */}
      <div className="fixed bottom-6 right-6">
        <Button
          size="lg"
          className="rounded-full shadow-lg shadow-blue-500/25 !px-5 !py-3"
          onClick={() => setShowAddModal(true)}
        >
          + Add Holding
        </Button>
      </div>

      {activePortfolio && (
        <AddHoldingModal
          isOpen={showAddModal}
          onClose={() => setShowAddModal(false)}
          portfolioId={activePortfolio.id}
          onAdded={() => {
            setShowAddModal(false);
            refresh();
          }}
        />
      )}
    </div>
  );
}

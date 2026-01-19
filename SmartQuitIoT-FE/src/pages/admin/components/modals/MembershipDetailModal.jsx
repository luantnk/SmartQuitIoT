import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Separator } from "@/components/ui/separator";
import {
  getMembershipPackagesDetail,
  updateMembershipPackage,
} from "@/services/membershipPackage";
import { formatCurrency } from "@/utils/currencyFormat";
import {
  Calendar,
  CheckCircle2,
  Clock,
  DollarSign,
  Info,
  Loader2,
  Package,
  X,
} from "lucide-react";
import { useEffect, useMemo, useRef, useState } from "react";
import { toast } from "sonner";

const getPackageTypeBadge = (type) => {
  switch (type) {
    case "TRIAL":
      return (
        <Badge
          variant="outline"
          className="bg-blue-50 text-blue-700 border-blue-200"
        >
          Trial
        </Badge>
      );
    case "STANDARD":
      return (
        <Badge className="bg-green-500 hover:bg-green-600">Standard</Badge>
      );
    case "PREMIUM":
      return (
        <Badge className="bg-yellow-500 hover:bg-amber-600">Premium</Badge>
      );
    default:
      return <Badge variant="outline">{type}</Badge>;
  }
};

const MembershipDetailModal = ({ isOpen, onOpenChange, id }) => {
  if (!id) return null;

  const [membershipPackage, setMembershipPackage] = useState(null);
  const [plans, setPlans] = useState([]);
  const [isEditPrice, setIsEditPrice] = useState(false);
  const [newPrice, setNewPrice] = useState(null);
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState("");

  const inputRef = useRef(null);

  const currentPrice = membershipPackage?.price ?? 0;
  const parsedNewPrice = useMemo(() => Number(newPrice), [newPrice]);
  const hasChanges =
    isEditPrice &&
    newPrice !== null &&
    !Number.isNaN(parsedNewPrice) &&
    parsedNewPrice !== currentPrice;
  const isInvalid =
    isEditPrice &&
    (newPrice === null ||
      Number.isNaN(parsedNewPrice) ||
      parsedNewPrice < 0 ||
      !Number.isFinite(parsedNewPrice));

  const fetchMembershipPackageDetail = async () => {
    try {
      const response = await getMembershipPackagesDetail(id);
      setMembershipPackage(response.data?.membershipPackage);
      setPlans(response.data?.plans);
    } catch (error) {
      console.error("Error fetching membership package detail:", error);
    }
  };

  useEffect(() => {
    if (id) {
      fetchMembershipPackageDetail();
    }
  }, [id]);

  // Autofocus when entering edit mode
  useEffect(() => {
    if (isEditPrice && inputRef.current) {
      inputRef.current.focus();
      inputRef.current.select?.();
    }
  }, [isEditPrice]);

  const handleEditPrice = (pkg) => {
    if (pkg?.type === "TRIAL") return;
    setNewPrice(pkg?.price ?? 0);
    setError("");
    setIsEditPrice(true);
  };

  const handleCancelEdit = () => {
    setIsEditPrice(false);
    setNewPrice(null);
    setError("");
  };

  const handleUpdatePrice = async () => {
    // Basic validation
    if (isInvalid || !hasChanges) return;
    try {
      setIsSaving(true);
      setError("");
      if (newPrice <= 0) {
        setError("Price must be greater than 0.");
        return;
      } else if (newPrice > 100000000) {
        setError("Price must not exceed 100,000,000 VND.");
        return;
      }
      const response = await updateMembershipPackage(id, parsedNewPrice);
      toast.success(response.data?.message);
      setIsEditPrice(false);
      setNewPrice(null);
    } catch (e) {
      console.error(e);
      setError("Failed to update price. Please try again.");
    } finally {
      setIsSaving(false);
      fetchMembershipPackageDetail();
    }
  };

  const onPriceChange = (e) => {
    const val = e.target.value;
    setNewPrice(val === "" ? "" : Number(val));
    setError("");
  };

  const onPriceKeyDown = (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      handleUpdatePrice();
    } else if (e.key === "Escape") {
      e.preventDefault();
      handleCancelEdit();
    }
  };

  return (
    <Dialog
      open={isOpen}
      onOpenChange={(v) => {
        if (!v) handleCancelEdit();
        onOpenChange?.(v);
      }}
    >
      <DialogContent className="sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Package className="h-5 w-5 text-primary" />
            {membershipPackage?.name} Package
            {isEditPrice && (
              <Badge className="bg-amber-100 text-amber-700 border border-amber-200">
                Editing price
              </Badge>
            )}
          </DialogTitle>
          <DialogDescription>
            Detailed information about the membership package and available
            plans
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6">
          {isEditPrice && (
            <div className="flex items-start gap-2 rounded-md border border-amber-200 bg-amber-50 p-3 text-sm">
              <Info className="h-4 w-4 mt-0.5 text-amber-600" />
              <div>
                You are editing the base price. This affects savings shown on
                multi-month plans. Press Enter to save or Esc to cancel.
              </div>
            </div>
          )}

          {/* Package Overview */}
          <div className="rounded-lg border p-4 bg-card/50">
            <div className="flex items-start justify-between gap-3 mb-3">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <h3 className="text-lg font-semibold">
                    {membershipPackage?.name}
                  </h3>
                  {getPackageTypeBadge(membershipPackage?.type)}
                </div>
                <p className="text-sm text-muted-foreground">
                  {membershipPackage?.description}
                </p>
              </div>

              <div className="text-right w-full max-w-[240px]">
                <div className="text-xs text-muted-foreground">Base Price</div>

                {isEditPrice ? (
                  <div className="mt-1 space-y-1.5">
                    <div className="relative">
                      <span className="absolute left-2 top-1/2 -translate-y-1/2 text-muted-foreground text-xs">
                        ₫
                      </span>
                      <Input
                        ref={inputRef}
                        type="number"
                        min={0}
                        step="1000"
                        value={newPrice ?? ""}
                        onChange={onPriceChange}
                        onKeyDown={onPriceKeyDown}
                        className={`pl-6 pr-16 text-right ${
                          isInvalid
                            ? "border-red-500 focus-visible:ring-red-500"
                            : ""
                        }`}
                      />
                      <span className="absolute right-2 top-1/2 -translate-y-1/2 text-muted-foreground text-xs">
                        VND
                      </span>
                    </div>

                    <div className="flex items-center justify-between text-xs">
                      <span className="text-muted-foreground">Formatted</span>
                      <span className="font-medium">
                        {Number.isFinite(parsedNewPrice)
                          ? formatCurrency(parsedNewPrice)
                          : "—"}
                      </span>
                    </div>

                    {error ? (
                      <div className="text-xs text-red-600">{error}</div>
                    ) : isInvalid ? (
                      <div className="text-xs text-red-600">
                        Enter a valid non-negative number.
                      </div>
                    ) : !hasChanges ? (
                      <div className="text-xs text-muted-foreground">
                        Change the value to enable Save.
                      </div>
                    ) : null}
                  </div>
                ) : (
                  <div className="text-xl font-bold text-emerald-600">
                    {formatCurrency(membershipPackage?.price)}
                  </div>
                )}

                <div className="text-xs text-muted-foreground mt-1">
                  <Clock className="h-3 w-3 inline mr-1" />
                  {membershipPackage?.duration}{" "}
                  {membershipPackage?.durationUnit?.toLowerCase()}
                </div>
              </div>
            </div>

            {/* Features */}
            {membershipPackage?.features &&
              membershipPackage.features.length > 0 && (
                <>
                  <Separator className="my-3" />
                  <div>
                    <div className="text-sm font-medium mb-2">Features</div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
                      {membershipPackage.features.map((feature, idx) => (
                        <div
                          key={idx}
                          className="flex items-start gap-2 text-sm"
                        >
                          <CheckCircle2 className="h-4 w-4 text-emerald-600 mt-0.5 flex-shrink-0" />
                          <span>{feature}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </>
              )}
          </div>

          {/* Available Plans */}
          {plans && plans.length > 0 && (
            <div className={isEditPrice ? "opacity-90" : ""}>
              <div className="flex items-center gap-2 mb-3">
                <Calendar className="h-4 w-4 text-blue-600" />
                <h4 className="font-semibold">Available Plans</h4>
                <Badge variant="secondary">{plans.length} options</Badge>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                {plans.map((plan, idx) => (
                  <Card
                    key={idx}
                    className="border-2 hover:border-primary/50 transition-colors"
                  >
                    <CardContent className="p-4">
                      <div className="flex items-start justify-between gap-3">
                        <div className="flex-1">
                          <div className="text-sm text-muted-foreground mb-1">
                            Duration
                          </div>
                          <div className="font-semibold">
                            {plan.planDuration}{" "}
                            {plan.planDurationUnit?.toLowerCase()}
                          </div>
                        </div>
                        <div className="text-right">
                          <div className="text-sm text-muted-foreground mb-1">
                            Price
                          </div>
                          <div className="text-lg font-bold text-emerald-600">
                            {formatCurrency(plan.planPrice)}
                          </div>
                        </div>
                      </div>

                      {plan.planDuration > 1 && (
                        <div className="mt-3 pt-3 border-t">
                          <div className="flex items-center justify-between text-xs">
                            <span className="text-muted-foreground">
                              Per month
                            </span>
                            <span className="font-medium">
                              {formatCurrency(
                                plan.planPrice / plan.planDuration
                              )}
                            </span>
                          </div>
                          <div className="flex items-center gap-1 mt-1">
                            <DollarSign className="h-3 w-3 text-emerald-600" />
                            <span className="text-xs text-emerald-600 font-medium">
                              Save{" "}
                              {Math.round(
                                ((currentPrice * plan.planDuration -
                                  plan.planPrice) /
                                  (currentPrice * plan.planDuration)) *
                                  100
                              )}
                              % with this plan
                            </span>
                          </div>
                        </div>
                      )}
                    </CardContent>
                  </Card>
                ))}
              </div>
            </div>
          )}
        </div>

        <DialogFooter className="gap-2">
          {isEditPrice ? (
            <>
              <Button
                type="button"
                variant="outline"
                onClick={handleCancelEdit}
                disabled={isSaving}
              >
                <X className="h-4 w-4 mr-2" />
                Cancel
              </Button>
              <Button
                type="button"
                onClick={handleUpdatePrice}
                disabled={isSaving || isInvalid || !hasChanges}
              >
                {isSaving ? (
                  <>
                    <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <CheckCircle2 className="h-4 w-4 mr-2" />
                    Save changes
                  </>
                )}
              </Button>
            </>
          ) : (
            <>
              <Button
                type="button"
                onClick={() => handleEditPrice(membershipPackage)}
                disabled={membershipPackage?.type === "TRIAL"}
              >
                <Package className="h-4 w-4 mr-2" />
                Edit Package
              </Button>
              <DialogClose asChild>
                <Button type="button" variant="outline">
                  Close
                </Button>
              </DialogClose>
            </>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

export default MembershipDetailModal;

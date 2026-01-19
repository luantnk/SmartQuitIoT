import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Separator } from "@/components/ui/separator";
import { useEffect, useMemo, useState } from "react";

import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { getMemberMetrics } from "@/services/metricService";
import { BadgeCheck, Clock, HeartPulse, Stethoscope } from "lucide-react";
import { toast } from "sonner";

const NAME_MAP = {
  PULSE_RATE: "Pulse Rate",
  OXYGEN_LEVEL: "Blood Oxygen Level",
  CARBON_MONOXIDE_LEVEL: "CO Level",
  TASTE_AND_SMELL: "Taste & Smell",
  NICOTINE_EXPELLED_FROM_BODY: "Nicotine Expelled",
  CIRCULATION: "Circulation",
  BREATHING: "Breathing",
  REDUCED_RISK_OF_HEART_DISEASE: "Reduced Heart Disease Risk",
  DECREASED_RISK_OF_HEART_ATTACK: "Stroke & Heart Attack Risk",
  IMMUNITY_AND_LUNG_FUNCTION: "Immunity & Lung Function",
};

const iconFor = (name) => {
  switch (name) {
    case "PULSE_RATE":
      return HeartPulse;
    case "BREATHING":
    case "CIRCULATION":
      return Stethoscope;
    default:
      return BadgeCheck;
  }
};

const clamp = (v, min = 0, max = 100) => Math.max(min, Math.min(max, v));

const minutesBetween = (from, to) =>
  Math.max(0, Math.floor((new Date(to) - new Date(from)) / 60000));

const fmtDateTime = (d) =>
  new Date(d).toLocaleString(undefined, {
    year: "numeric",
    month: "short",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });

const fmtDuration = (mins) => {
  if (mins <= 0) return "now";
  if (mins < 60) return `${mins}m`;
  const h = Math.floor(mins / 60);
  const m = mins % 60;
  if (h < 24) return `${h}h ${m}m`;
  const d = Math.floor(h / 24);
  const rh = h % 24;
  return `${d}d ${rh}h`;
};

const levelToPercent = (v = 0, max = 10) => clamp(Math.round((v / max) * 100));

const currency = (v) =>
  new Intl.NumberFormat(undefined, {
    style: "currency",
    currency: "VND",
  }).format(v || 0);

const MemberHealthModal = ({ memberId, isOpen, onOpenChange }) => {
  const [loading, setLoading] = useState(false);
  const [data, setData] = useState(null); // { healthRecoveries: [], metrics: {} }

  const fetchData = async () => {
    setLoading(true);
    try {
      const res = await getMemberMetrics(memberId);
      setData(res.data);
    } catch (error) {
      console.log(error);
      toast.error("Failed to load member health data.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!isOpen) return;
    fetchData();
  }, [isOpen, memberId]);

  const now = useMemo(() => new Date(), [isOpen]);

  const recoveries = data?.healthRecoveries || [];
  const metrics = data?.metrics || null;

  const computeTimeProgress = (item) => {
    const total = minutesBetween(item.timeTriggered, item.targetTime);
    const passed = minutesBetween(item.timeTriggered, now);
    if (total <= 0) return 100;
    return clamp(Math.round((passed / total) * 100));
  };

  const timeLeftLabel = (item) => {
    const left = minutesBetween(now, item.targetTime);
    const done = left === 0 || new Date(item.targetTime) <= now;
    return done ? "Completed" : `ETA ${fmtDuration(left)}`;
  };

  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-6xl h-full overflow-hidden">
        <DialogHeader>
          <DialogTitle>Member Health Overview</DialogTitle>
          <DialogDescription>Overview for member #{memberId}</DialogDescription>
        </DialogHeader>

        {/* Top meta */}
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Clock className="h-4 w-4" />
          Updated at:
          <span className="font-medium">
            {metrics?.updatedAt ? fmtDateTime(metrics.updatedAt) : "—"}
          </span>
        </div>

        {/* Tabs */}
        <Tabs defaultValue="recoveries" className="w-full">
          <TabsList className="grid grid-cols-2 w-full">
            <TabsTrigger value="recoveries">Recoveries</TabsTrigger>
            <TabsTrigger value="metrics">Metrics</TabsTrigger>
          </TabsList>

          {/* Recoveries */}
          <TabsContent value="recoveries" className="mt-4">
            {loading ? (
              <div className="space-y-3">
                <div className="h-5 w-48 bg-muted rounded" />
                <div className="h-24 bg-muted rounded" />
                <div className="h-24 bg-muted rounded" />
                <div className="h-24 bg-muted rounded" />
              </div>
            ) : (
              <ScrollArea className="h-[660px] pr-2">
                <div className="space-y-3">
                  {recoveries.map((r) => {
                    const Icon = iconFor(r.name);
                    const progress =
                      typeof r.value === "number"
                        ? clamp(r.value)
                        : computeTimeProgress(r);
                    const isCompleted =
                      new Date(r.targetTime) <= now || progress >= 100;

                    return (
                      <div
                        key={r.id}
                        className="rounded-lg border p-4 bg-card/50"
                      >
                        <div className="flex items-start justify-between gap-3">
                          <div className="flex items-center gap-2">
                            <span className="inline-flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-primary">
                              <Icon className="h-4 w-4" />
                            </span>
                            <div>
                              <div className="flex items-center gap-2">
                                <h4 className="font-semibold">
                                  {NAME_MAP[r.name] || r.name}
                                </h4>
                                <Badge
                                  variant={
                                    isCompleted ? "default" : "secondary"
                                  }
                                  className={
                                    isCompleted
                                      ? "bg-emerald-500 hover:bg-emerald-600"
                                      : ""
                                  }
                                >
                                  {isCompleted ? "Completed" : "In progress"}
                                </Badge>
                              </div>
                              <p className="text-sm text-muted-foreground mt-1">
                                {r.description}
                              </p>
                            </div>
                          </div>
                          <div className="text-right min-w-[140px]">
                            <div className="text-xs text-muted-foreground">
                              Target
                            </div>
                            <div className="text-sm font-medium">
                              {fmtDateTime(r.targetTime)}
                            </div>
                            <div className="text-xs mt-1 text-muted-foreground">
                              {timeLeftLabel(r)}
                            </div>
                          </div>
                        </div>

                        <div className="mt-4 space-y-1.5">
                          <div className="flex items-center justify-between text-xs text-muted-foreground">
                            <span>Progress</span>
                            <span className="font-medium">{progress}%</span>
                          </div>
                          <Progress value={progress} className={``} />
                        </div>
                      </div>
                    );
                  })}
                </div>
              </ScrollArea>
            )}
          </TabsContent>

          {/* Metrics */}
          <TabsContent value="metrics" className="mt-4">
            {loading ? (
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                <div className="h-20 bg-muted rounded" />
                <div className="h-20 bg-muted rounded" />
                <div className="h-20 bg-muted rounded" />
                <div className="h-20 bg-muted rounded" />
                <div className="h-20 bg-muted rounded" />
                <div className="h-20 bg-muted rounded" />
              </div>
            ) : (
              <>
                {/* Quick KPIs */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  <MetricBox label="Streaks" value={metrics?.streaks} />
                  <MetricBox
                    label="Relapses"
                    value={metrics?.relapseCountInPhase}
                  />
                  <MetricBox label="Posts" value={metrics?.post_count} />
                  <MetricBox label="Comments" value={metrics?.comment_count} />
                </div>

                <Separator className="my-4" />

                {/* Feelings (1-5) */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <LevelBox
                    title="Average Levels"
                    items={[
                      {
                        name: "Craving",
                        value: metrics?.avgCravingLevel ?? 0,
                      },
                      { name: "Mood", value: metrics?.avgMood ?? 0 },
                      { name: "Anxiety", value: metrics?.avgAnxiety ?? 0 },
                      {
                        name: "Confidence",
                        value: metrics?.avgConfidentLevel ?? 0,
                      },
                    ]}
                  />
                  <LevelBox
                    title="Current Levels"
                    items={[
                      {
                        name: "Craving",
                        value: metrics?.currentCravingLevel ?? 0,
                      },
                      { name: "Mood", value: metrics?.currentMoodLevel ?? 0 },
                      {
                        name: "Anxiety",
                        value: metrics?.currentAnxietyLevel ?? 0,
                      },
                      {
                        name: "Confidence",
                        value: metrics?.currentConfidenceLevel ?? 0,
                      },
                    ]}
                  />
                </div>

                <Separator className="my-4" />

                {/* Activity */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  <MetricBox label="Steps" value={metrics?.steps} />
                  <MetricBox
                    label="Heart rate"
                    value={`${metrics?.heartRate} bpm`}
                  />
                  <MetricBox label="SpO₂" value={`${metrics?.spo2}%`} />
                  <MetricBox
                    label="Sleep"
                    value={`${metrics?.sleepDuration} h`}
                  />
                </div>

                <Separator className="my-4" />

                {/* Savings / Progress */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="rounded-lg border p-4">
                    <div className="text-sm text-muted-foreground">
                      Savings (annual estimate)
                    </div>
                    <div className="text-2xl font-bold mt-1">
                      {currency(metrics?.annualSaved || 0)}
                    </div>
                    <div className="mt-3">
                      <div className="flex items-center justify-between text-xs">
                        <span>Saved so far</span>
                        <span className="font-medium">
                          {currency(metrics?.moneySaved || 0)}
                        </span>
                      </div>
                      <Progress
                        className="mt-1.5"
                        value={clamp(metrics?.reductionPercentage || 0)}
                      />
                      <div className="text-xs text-muted-foreground mt-1">
                        Reduction: {clamp(metrics?.reductionPercentage || 0)}%
                      </div>
                    </div>
                  </div>

                  <div className="rounded-lg border p-4">
                    <div className="text-sm text-muted-foreground">
                      Smoke-free days
                    </div>
                    <div className="mt-3">
                      <div className="flex items-center justify-between text-xs">
                        <span>Progress</span>
                        <span className="font-medium">
                          {clamp(metrics?.smokeFreeDayPercentage || 0)}%
                        </span>
                      </div>
                      <Progress
                        className="mt-1.5"
                        value={clamp(metrics?.smokeFreeDayPercentage || 0)}
                      />
                    </div>
                  </div>
                </div>
              </>
            )}
          </TabsContent>
        </Tabs>

        <DialogFooter>
          <DialogClose asChild>
            <Button type="button" variant="outline">
              Close
            </Button>
          </DialogClose>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

/* Small subcomponents */

const MetricBox = ({ label, value }) => (
  <div className="rounded-lg border p-4 bg-card/50">
    <div className="text-xs text-muted-foreground">{label}</div>
    <div className="text-xl font-semibold">{value ?? "—"}</div>
  </div>
);

const LevelBox = ({ title, items }) => (
  <div className="rounded-lg border p-4 bg-card/50">
    <div className="space-y-3">
      {items.map((it) => (
        <div key={it.name}>
          <div className="flex items-center justify-between text-xs">
            <span>{it.name}</span>
            <span className="font-medium">{it.value ?? 0}/10</span>
          </div>
          <Progress className="mt-1.5" value={levelToPercent(it.value ?? 0)} />
        </div>
      ))}
    </div>
  </div>
);

export default MemberHealthModal;

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import { Badge } from "@/components/ui/badge";
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
import { Progress } from "@/components/ui/progress";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { getQuitPlanByMemberId } from "@/services/quitPlanService";
import {
  CalendarDays,
  Clock,
  Hourglass,
  Info,
  ListChecks,
  PackageCheck,
  Target,
} from "lucide-react";
import { useEffect, useMemo, useState } from "react";

const fmtDate = (d) =>
  d
    ? new Date(d).toLocaleDateString(undefined, {
        year: "numeric",
        month: "short",
        day: "2-digit",
      })
    : "—";

const diffDays = (from, to) => {
  if (!from || !to) return 0;
  const a = new Date(from);
  const b = new Date(to);
  return Math.max(0, Math.round((b - a) / (1000 * 60 * 60 * 24)) + 1);
};

const statusBadge = (status) => {
  switch (status) {
    case "IN_PROGRESS":
      return (
        <Badge className="bg-emerald-500 hover:bg-emerald-600">
          In Progress
        </Badge>
      );
    case "COMPLETED":
      return <Badge className="bg-blue-600 hover:bg-blue-700">Completed</Badge>;
    case "CREATED":
      return <Badge variant="secondary">Not Started</Badge>;
    case "CANCELED":
      return <Badge className="bg-red-600 hover:bg-red-700">Cancelled</Badge>;
    default:
      return <Badge variant="secondary">--</Badge>;
  }
};

const ratio = (a = 0, b = 0) =>
  b > 0 ? Math.min(100, Math.round((a / b) * 100)) : 0;

const PhaseHeader = ({ phase }) => {
  const total = phase?.totalMissions || 0;
  const done = phase?.completedMissions || 0;
  const percent = phase?.progress ?? ratio(done, total);
  return (
    <div className="space-y-2 text-left">
      <div className="flex items-center gap-2">
        <Target className="h-4 w-4 text-emerald-600" />
        <span className="font-semibold">{phase?.name}</span>
        <Badge variant="outline" className="ml-2">
          {fmtDate(phase?.startDate)} – {fmtDate(phase?.endDate)}
        </Badge>
        <Badge variant="secondary" className="ml-1">
          {phase?.durationDay} days
        </Badge>
      </div>
      <div className="flex items-center gap-2 text-xs text-muted-foreground">
        <PackageCheck className="h-3.5 w-3.5" />
        {done}/{total} missions completed
      </div>
      <Progress value={percent} />
    </div>
  );
};

const MissionItem = ({ mission }) => (
  <div className="rounded-md border p-3 bg-card/50">
    <div className="flex items-start justify-between gap-3">
      <div>
        <div className="font-medium">{mission.name}</div>
        <p className="text-xs text-muted-foreground mt-1">
          {mission.description}
        </p>
      </div>
      <Badge
        variant={mission.status === "COMPLETED" ? "default" : "secondary"}
        className={
          mission.status === "COMPLETED"
            ? "bg-emerald-500 hover:bg-emerald-600"
            : ""
        }
      >
        {mission.status === "COMPLETED" ? "Completed" : "Incomplete"}
      </Badge>
    </div>
  </div>
);

const KeyValue = ({ label, value }) => (
  <div className="rounded-lg border p-4">
    <div className="text-xs text-muted-foreground">{label}</div>
    <div className="text-lg font-semibold">{value ?? "—"}</div>
  </div>
);

const Money = ({ v }) =>
  new Intl.NumberFormat(undefined, {
    style: "currency",
    currency: "VND",
  }).format(v || 0);

const MemberCurrentPlanModal = ({ isOpen, onOpenChange, memberId }) => {
  const [plan, setPlan] = useState(null);

  const fetchPlan = async () => {
    try {
      const response = await getQuitPlanByMemberId(memberId);
      setPlan(response.data);
    } catch (error) {
      console.log(error);
      toast.error("Failed to load member quit plan.");
    }
  };

  useEffect(() => {
    if (isOpen && memberId) {
      fetchPlan();
    }
  }, [isOpen, memberId]);

  const overall = useMemo(() => {
    if (!plan?.phases?.length) return { total: 0, done: 0, percent: 0 };
    const sumTotal = plan.phases.reduce(
      (s, p) => s + (p.totalMissions || 0),
      0
    );
    const sumDone = plan.phases.reduce(
      (s, p) => s + (p.completedMissions || 0),
      0
    );
    const percent = ratio(sumDone, sumTotal);
    return { total: sumTotal, done: sumDone, percent };
  }, [plan]);

  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-7xl h-full">
        <DialogHeader>
          <DialogTitle>Current Quit Plan</DialogTitle>
          <DialogDescription>
            {memberId ? `Overview for member #${memberId}` : "Plan overview"}
          </DialogDescription>
        </DialogHeader>

        {!plan ? (
          <div className="h-48 grid place-items-center text-muted-foreground">
            No plan data.
          </div>
        ) : (
          <>
            {/* Plan summary */}
            <div className="space-y-2">
              <div className="flex flex-wrap items-center gap-2">
                <span className="text-xl font-semibold">{plan.name}</span>
                {statusBadge(plan.status)}
                {plan.useNRT && <Badge variant="outline">Using NRT</Badge>}
              </div>
              <div className="flex flex-wrap items-center gap-3 text-sm text-muted-foreground">
                <span className="inline-flex items-center gap-1">
                  <CalendarDays className="h-4 w-4" />
                  {fmtDate(plan.startDate)} – {fmtDate(plan.endDate)}
                </span>
                <span className="inline-flex items-center gap-1">
                  <Hourglass className="h-4 w-4" />
                  {diffDays(plan.startDate, plan.endDate)} days
                </span>
                <span className="inline-flex items-center gap-1">
                  <Info className="h-4 w-4" />
                  FTND:{" "}
                  <span className="font-medium ml-1">{plan.ftndScore}</span>
                </span>
              </div>

              <div className="mt-3">
                <div className="flex items-center justify-between text-xs text-muted-foreground">
                  <span>Current progress</span>
                  <span className="font-medium">
                    {overall.done}/{overall.total} ({overall.percent}%)
                  </span>
                </div>
                <Progress className="mt-1.5" value={overall.percent} />
              </div>
            </div>

            <Separator className="my-4" />

            <Tabs defaultValue="overview" className="w-full">
              <TabsList className="grid grid-cols-3 w-full">
                <TabsTrigger value="overview">Overview</TabsTrigger>
                <TabsTrigger value="phases">Phases</TabsTrigger>
                <TabsTrigger value="form">Form Metrics</TabsTrigger>
              </TabsList>

              {/* Overview */}
              <TabsContent value="overview" className="mt-4">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  <KeyValue
                    label="Avg cigarettes/day"
                    value={plan.formMetricDTO?.smokeAvgPerDay}
                  />
                  <KeyValue
                    label="Years of smoking"
                    value={plan.formMetricDTO?.numberOfYearsOfSmoking}
                  />
                  <KeyValue
                    label="Cigs per pack"
                    value={plan.formMetricDTO?.cigarettesPerPackage}
                  />
                  <KeyValue
                    label="Money per pack"
                    value={Money({ v: plan.formMetricDTO?.moneyPerPackage })}
                  />
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-3">
                  <KeyValue
                    label="Est. nicotine intake/day"
                    value={`${
                      plan.formMetricDTO?.estimatedNicotineIntakePerDay ?? 0
                    } mg`}
                  />
                  <KeyValue
                    label="Est. money saved (plan)"
                    value={Money({
                      v: plan.formMetricDTO?.estimatedMoneySavedOnPlan,
                    })}
                  />
                </div>

                {Array.isArray(plan.formMetricDTO?.interests) &&
                  plan.formMetricDTO.interests.length > 0 && (
                    <>
                      <Separator className="my-4" />
                      <div>
                        <div className="text-sm text-muted-foreground mb-2">
                          Interests
                        </div>
                        <div className="flex flex-wrap gap-2">
                          {plan.formMetricDTO.interests.map((it) => (
                            <Badge key={it} variant="secondary">
                              {it}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    </>
                  )}
              </TabsContent>

              {/* Phases */}
              <TabsContent value="phases" className="mt-4">
                {!plan.phases || plan.phases.length === 0 ? (
                  <div className="h-32 grid place-items-center text-muted-foreground">
                    No phases available.
                  </div>
                ) : (
                  <ScrollArea className="h-[420px] pr-2">
                    <Accordion type="single" collapsible className="w-full">
                      {plan.phases.map((phase) => (
                        <AccordionItem
                          key={phase.id}
                          value={`phase-${phase.id}`}
                        >
                          <AccordionTrigger>
                            <PhaseHeader phase={phase} />
                          </AccordionTrigger>
                          <AccordionContent>
                            <div className="space-y-4">
                              {/* Reason */}
                              {phase.reason && (
                                <div className="rounded-lg border p-4 bg-card/50">
                                  <div className="text-xs text-muted-foreground mb-1">
                                    Reason
                                  </div>
                                  <p className="text-sm">{phase.reason}</p>
                                </div>
                              )}

                              {/* Conditions */}
                              {phase.condition && (
                                <div className="rounded-lg border p-4 bg-card/50">
                                  <div className="flex items-center gap-2 mb-1">
                                    <Info className="h-4 w-4 text-blue-600" />
                                    <span className="text-sm font-medium">
                                      Phase Conditions
                                    </span>
                                  </div>
                                  <pre className="text-xs text-muted-foreground whitespace-pre-wrap">
                                    {JSON.stringify(phase.condition, null, 2)}
                                  </pre>
                                </div>
                              )}

                              {/* Daily details */}
                              {phase.details && phase.details.length > 0 ? (
                                <div className="space-y-3">
                                  {phase.details.map((d) => (
                                    <div
                                      key={d.id}
                                      className="rounded-lg border p-4"
                                    >
                                      <div className="flex flex-wrap items-center justify-between gap-2">
                                        <div className="flex items-center gap-2">
                                          <ListChecks className="h-4 w-4 text-purple-600" />
                                          <div className="font-semibold">
                                            {d.name} • {fmtDate(d.date)}
                                          </div>
                                        </div>
                                        <div className="text-xs text-muted-foreground">
                                          Missions: {d.missionCompleted}/
                                          {d.totalMission}
                                        </div>
                                      </div>

                                      <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-3">
                                        {(d.missions || []).map((m) => (
                                          <MissionItem key={m.id} mission={m} />
                                        ))}
                                      </div>
                                    </div>
                                  ))}
                                </div>
                              ) : (
                                <div className="flex items-center gap-2 text-sm text-muted-foreground">
                                  <Clock className="h-4 w-4" />
                                  No daily details for this phase.
                                </div>
                              )}
                            </div>
                          </AccordionContent>
                        </AccordionItem>
                      ))}
                    </Accordion>
                  </ScrollArea>
                )}
              </TabsContent>

              {/* Form metrics (full) */}
              <TabsContent value="form" className="mt-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                  <KeyValue
                    label="Avg/day"
                    value={plan.formMetricDTO?.smokeAvgPerDay}
                  />
                  <KeyValue
                    label="Years"
                    value={plan.formMetricDTO?.numberOfYearsOfSmoking}
                  />
                  <KeyValue
                    label="Per package"
                    value={plan.formMetricDTO?.cigarettesPerPackage}
                  />
                  <KeyValue
                    label="Min after wake to smoke"
                    value={`${
                      plan.formMetricDTO?.minutesAfterWakingToSmoke ?? 0
                    } min`}
                  />
                  <KeyValue
                    label="Money/pack"
                    value={Money({ v: plan.formMetricDTO?.moneyPerPackage })}
                  />
                  <KeyValue
                    label="Est. saved (plan)"
                    value={Money({
                      v: plan.formMetricDTO?.estimatedMoneySavedOnPlan,
                    })}
                  />
                  <KeyValue
                    label="Nicotine per cig"
                    value={`${
                      plan.formMetricDTO?.amountOfNicotinePerCigarettes ?? 0
                    } mg`}
                  />
                  <KeyValue
                    label="Est. nicotine/day"
                    value={`${
                      plan.formMetricDTO?.estimatedNicotineIntakePerDay ?? 0
                    } mg`}
                  />
                </div>

                <Separator className="my-4" />

                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  <KeyValue
                    label="Smoke in forbidden places"
                    value={
                      plan.formMetricDTO?.smokingInForbiddenPlaces
                        ? "Yes"
                        : "No"
                    }
                  />
                  <KeyValue
                    label="Hate to give up"
                    value={
                      plan.formMetricDTO?.cigaretteHateToGiveUp ? "Yes" : "No"
                    }
                  />
                  <KeyValue
                    label="Morning smoking frequency"
                    value={
                      plan.formMetricDTO?.morningSmokingFrequency ? "Yes" : "No"
                    }
                  />
                  <KeyValue
                    label="Smoke when sick"
                    value={plan.formMetricDTO?.smokeWhenSick ? "Yes" : "No"}
                  />
                </div>
              </TabsContent>
            </Tabs>
          </>
        )}

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

export default MemberCurrentPlanModal;

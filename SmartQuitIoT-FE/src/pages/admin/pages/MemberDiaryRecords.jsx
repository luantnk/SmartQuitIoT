import React, { useEffect, useMemo, useState } from "react";
import { useParams } from "react-router-dom";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import {
  getDiaryRecordChartsByMemberId,
  getDiaryRecordHistoryByMemberId,
} from "@/services/diaryRecordService";
import { toast } from "sonner";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  ResponsiveContainer,
  LineChart,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Line,
} from "recharts";
import { Award, Calendar, Cigarette } from "lucide-react";
import { ScrollArea } from "@/components/ui/scroll-area";
import HasSmoked from "@/components/ui/icons/has-smoked";
import NoSmoked from "@/components/ui/icons/no-somked";

const buildSingleSeries = (data, key) => {
  const arr = data?.[key] ?? [];
  return arr
    .filter((i) => i?.date != null && i?.[key] != null)
    .sort((a, b) => new Date(a.date) - new Date(b.date))
    .map((i) => ({ date: i.date, value: i[key] }));
};

const formatDateTick = (d) =>
  new Date(d).toLocaleDateString(undefined, { month: "short", day: "2-digit" });

const formatTooltipLabel = (d) =>
  new Date(d).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "2-digit",
  });

const fmtDate = (d) =>
  new Date(d).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "2-digit",
  });

const MemberDiaryRecords = () => {
  const [chartData, setChartData] = useState(null);
  const [recordHistory, setRecordHistory] = useState([]);

  const { memberId } = useParams();

  const fetchChartData = async () => {
    try {
      const response = await getDiaryRecordChartsByMemberId(memberId);
      setChartData(response.data);
    } catch (error) {
      console.log(error);
      toast.error("Failed to fetch diary record charts.");
    }
  };

  const fetchRecordHistory = async () => {
    try {
      const response = await getDiaryRecordHistoryByMemberId(memberId);
      setRecordHistory(response.data);
    } catch (error) {
      console.log(error);
      toast.error("Failed to fetch diary record history.");
    }
  };

  useEffect(() => {
    fetchChartData();
    fetchRecordHistory();
  }, [memberId]);

  const moodSeries = useMemo(
    () => buildSingleSeries(chartData, "moodLevel"),
    [chartData]
  );
  const confidenceSeries = useMemo(
    () => buildSingleSeries(chartData, "confidenceLevel"),
    [chartData]
  );
  const cravingSeries = useMemo(
    () => buildSingleSeries(chartData, "cravingLevel"),
    [chartData]
  );
  const anxietySeries = useMemo(
    () => buildSingleSeries(chartData, "anxietyLevel"),
    [chartData]
  );

  const hasAnyData =
    moodSeries.length ||
    confidenceSeries.length ||
    cravingSeries.length ||
    anxietySeries.length;

  const ChartCard = ({ title, color, data }) => (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        {!data || data.length === 0 ? (
          <div className="h-56 grid place-items-center text-muted-foreground">
            No data available.
          </div>
        ) : (
          <div className="h-56 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart
                data={data}
                margin={{ top: 10, right: 16, left: 0, bottom: 0 }}
              >
                <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
                <XAxis
                  dataKey="date"
                  tickFormatter={formatDateTick}
                  tick={{ fontSize: 12, fill: "#6b7280" }}
                />
                <YAxis
                  domain={[0, 10]}
                  ticks={[0, 2, 4, 6, 8, 10]}
                  tick={{ fontSize: 12, fill: "#6b7280" }}
                />
                <Tooltip
                  labelFormatter={formatTooltipLabel}
                  formatter={(value) => [value, title]}
                />
                <Line
                  type="monotone"
                  dataKey="value"
                  stroke={color}
                  strokeWidth={2}
                  dot={{ r: 3 }}
                  connectNulls
                  activeDot={{ r: 5 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        )}
      </CardContent>
    </Card>
  );

  const RecordsHistoryList = ({ records }) => (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
      <div className="p-6 border-b border-gray-200">
        <h2 className="text-xl font-semibold text-gray-900">Daily Records</h2>
      </div>

      <div className="overflow-x-auto">
        {/* Header table (non-scrollable) */}
        <table className="w-full">
          <colgroup>
            <col className="w-[40%]" />
            <col className="w-[20%]" />
            <col className="w-[20%]" />
            <col className="w-[20%]" />
          </colgroup>
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Date
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Status
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Nicotine Intake
              </th>
              <th className="px-6 py-4 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">
                Reduction
              </th>
            </tr>
          </thead>
        </table>

        {/* Scrollable body */}
        <ScrollArea className="h-80">
          <table className="w-full">
            <colgroup>
              <col className="w-[40%]" />
              <col className="w-[20%]" />
              <col className="w-[20%]" />
              <col className="w-[20%]" />
            </colgroup>
            <tbody className="divide-y divide-gray-200">
              {records.map((record) => (
                <tr
                  key={record.id}
                  className="hover:bg-gray-50 transition-colors"
                >
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center">
                        {record.haveSmoked ? <HasSmoked /> : <NoSmoked />}
                      </div>
                      <div>
                        <p className="font-medium text-gray-900">
                          {new Date(record.date).toLocaleDateString("en-US", {
                            month: "long",
                            day: "numeric",
                            year: "numeric",
                          })}
                        </p>
                        <p className="text-xs text-gray-500">ID: {record.id}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    {record.haveSmoked ? (
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-full bg-orange-100 flex items-center justify-center">
                          <Cigarette className="w-4 h-4 text-orange-600" />
                        </div>
                        <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-orange-100 text-orange-700">
                          Smoked
                        </span>
                      </div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center">
                          <Award className="w-4 h-4 text-green-600" />
                        </div>
                        <span className="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-700">
                          Smoke-Free
                        </span>
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <span className="text-2xl font-bold text-gray-900">
                        {record.estimatedNicotineIntake}
                      </span>
                      <span className="text-sm text-gray-500">mg</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="flex-1 max-w-xs">
                        <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                          <div
                            className="h-full bg-green-500 rounded-full transition-all"
                            style={{ width: `${record.reductionPercentage}%` }}
                          />
                        </div>
                      </div>
                      <span className="text-sm font-semibold text-gray-900 w-12 text-right">
                        {record.reductionPercentage}%
                      </span>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </ScrollArea>
      </div>
    </div>
  );

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb
        paths={["admin", "manage-members", memberId, "diary-records"]}
      />

      {!chartData || !hasAnyData ? (
        <Card>
          <CardHeader>
            <CardTitle>Diary Levels</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-64 grid place-items-center text-muted-foreground">
              No data available.
            </div>
          </CardContent>
        </Card>
      ) : (
        <>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <ChartCard title="Mood" color="#6366f1" data={moodSeries} />
            <ChartCard
              title="Confidence"
              color="#10b981"
              data={confidenceSeries}
            />
            <ChartCard title="Craving" color="#f59e0b" data={cravingSeries} />
            <ChartCard title="Anxiety" color="#ef4444" data={anxietySeries} />
          </div>
          <RecordsHistoryList records={recordHistory} />
        </>
      )}
    </div>
  );
};

export default MemberDiaryRecords;

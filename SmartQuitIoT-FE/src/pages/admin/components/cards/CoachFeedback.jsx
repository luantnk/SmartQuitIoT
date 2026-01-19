import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { getFeedbacksByCoachIdForAdmin } from "@/services/feedbackService";
import { formatDate, formatDateTime, formatTime } from "@/utils/formatDate";
import {
  Calendar,
  Clock,
  MessageCircle,
  MessageSquare,
  Star,
} from "lucide-react";
import { useEffect, useState } from "react";

const getRatingStars = (rating) => {
  return (
    <div className="flex items-center gap-1">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={`h-4 w-4 ${
            star <= rating ? "fill-yellow-400 text-yellow-400" : "text-gray-300"
          }`}
        />
      ))}
      <span className="ml-2 text-sm font-medium">{rating.toFixed(1)}</span>
    </div>
  );
};

const FeedbackCard = ({ feedback }) => {
  return (
    <Card className="border hover:border-primary/50 transition-colors">
      <CardContent className="p-4 space-y-3">
        {/* Header: Member & Rating */}
        <div className="flex items-start justify-between gap-3">
          <div className="flex items-center gap-3 flex-1">
            <Avatar className="h-10 w-10">
              <AvatarImage
                src={feedback?.avatarUrl}
                alt={feedback?.memberName}
              />
              <AvatarFallback className="text-xs">
                {feedback?.memberName
                  ?.split(" ")
                  .map((n) => n[0])
                  .join("")}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <div className="font-medium text-sm">{feedback?.memberName}</div>
              <div className="text-xs text-muted-foreground">
                {formatDateTime(feedback?.date)}
              </div>
            </div>
          </div>
          {getRatingStars(feedback?.rating)}
        </div>

        <Separator />

        {/* Feedback Content */}
        <div className="space-y-2">
          <div className="flex items-start gap-2">
            <MessageSquare className="h-4 w-4 text-blue-600 mt-0.5 flex-shrink-0" />
            <p className="text-sm text-gray-700 leading-relaxed">
              {feedback?.content || "No feedback content"}
            </p>
          </div>
        </div>

        <Separator />

        {/* Appointment Details */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-xs">
            <div className="flex items-center gap-1 text-muted-foreground">
              <Calendar className="h-3 w-3" />
              <span>Appointment Date</span>
            </div>
            <span className="font-medium">
              {formatDate(feedback?.appointmentDate)}
            </span>
          </div>
          <div className="flex items-center justify-between text-xs">
            <div className="flex items-center gap-1 text-muted-foreground">
              <Clock className="h-3 w-3" />
              <span>Time Slot</span>
            </div>
            <span className="font-medium">
              {formatTime(feedback?.startTime)} -{" "}
              {formatTime(feedback?.endTime)}
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

const CoachFeedback = ({ coachId }) => {
  if (!coachId) return null;

  const [feedbacks, setFeedbacks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(0);
  const [size] = useState(8);
  const [totalElements, setTotalElements] = useState(0);

  const fetchFeedbacks = async () => {
    try {
      setLoading(true);
      const response = await getFeedbacksByCoachIdForAdmin(coachId, page, size);
      if (response) {
        setFeedbacks(response?.content || []);
        setTotalElements(response?.page?.totalElements || 0);
      }
    } catch (error) {
      console.error("Error fetching feedbacks:", error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFeedbacks();
  }, [coachId, page]);

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <MessageCircle className="h-5 w-5" />
            Coach Feedback
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-32 bg-muted rounded animate-pulse" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  const averageRating =
    feedbacks.length > 0
      ? (
          feedbacks.reduce((sum, f) => sum + (f.rating || 0), 0) /
          feedbacks.length
        ).toFixed(1)
      : 0;

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle className="flex items-center gap-2">
            <MessageCircle className="h-5 w-5" />
            Coach Feedback
          </CardTitle>
          <div className="flex items-center gap-3">
            <div className="text-right">
              <div className="text-sm font-medium">
                {totalElements} {totalElements === 1 ? "review" : "reviews"}
              </div>
              <div className="flex items-center gap-1">
                <Star className="h-4 w-4 fill-amber-400 text-amber-400" />
                <span className="text-sm font-semibold">{averageRating}</span>
              </div>
            </div>
          </div>
        </div>
      </CardHeader>

      <CardContent>
        {feedbacks.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-12 text-center">
            <MessageCircle className="h-12 w-12 text-muted-foreground mb-3" />
            <p className="text-muted-foreground">No feedback available</p>
          </div>
        ) : (
          <div className="space-y-4">
            {feedbacks.map((feedback) => (
              <FeedbackCard key={feedback.id} feedback={feedback} />
            ))}

            {/* Pagination Info */}
            {totalElements > size && (
              <div className="text-xs text-muted-foreground text-center pt-4">
                Showing {feedbacks.length} of {totalElements} feedbacks
              </div>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default CoachFeedback;

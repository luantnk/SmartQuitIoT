import React, { useEffect, useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Client } from "@stomp/stompjs";
import { getAllSystemNotifications } from "@/services/notificationService";
import CardLoading from "@/components/loadings/CardLoading";
import { formatTimeAgo } from "@/utils/formatDate";
import { Car, CarFront } from "lucide-react";

const SystemActivityCard = ({ size }) => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(size || 10);

  const fetchNotifications = async () => {
    setLoading(true);
    try {
      const response = await getAllSystemNotifications(currentPage, pageSize);
      setNotifications(response.data?.content);
    } catch (error) {
      console.log(error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchNotifications();
  }, []);

  useEffect(() => {
    const connectSocket = (callback) => {
      const client = new Client({
        brokerURL:
          "ws://localhost:8080/api/ws" ||
          "wss://server.smartquitiot.website/api/ws",
        connectHeaders: {},
        reconnectDelay: 5000,
        onConnect: () => {
          console.log("Connected to WebSocket");
          client.subscribe(`/topic/system-activity`, (message) => {
            callback(message.body);
          });
        },
        onDisconnect: () => {
          console.log("Disconnected from WebSocket");
        },
      });
      client.activate();
      return client;
    };

    const handleData = (data) => {
      const parsedData = JSON.parse(data);
      setNotifications((prevNotifications) => [
        parsedData,
        ...prevNotifications,
      ]);
    };

    const client = connectSocket(handleData);
    return () => {
      if (client && client.connected) {
        client.deactivate();
      }
    };
  }, []);

  if (loading) {
    return <CardLoading title={"System Activities Loading.."} />;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>System Activity</CardTitle>
        <CardDescription>
          Recent system events and notifications
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          {notifications.map((notification) => (
            <div
              className="flex items-center space-x-3 p-3 bg-blue-50 rounded-lg"
              key={notification.id}
            >
              <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
              <div className="flex-1">
                <p className="text-sm font-medium">{notification.title}</p>
                <p className="text-xs text-gray-500">{notification.content}</p>
              </div>
              <span className="text-xs text-gray-400">
                {formatTimeAgo(notification.createdAt)}
              </span>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
};

export default SystemActivityCard;

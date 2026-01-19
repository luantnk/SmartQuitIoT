// utils/stompHelpers.js
export async function waitConnected(client, timeout = 5000) {
  if (!client) throw new Error("missing stomp client");
  if (client.connected) return;
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error("stomp connect timeout"));
    }, timeout);

    const prev = client.onConnect;
    client.onConnect = (frame) => {
      try {
        prev && prev(frame, client);
      } catch (e) {
        /*ignore*/
      }
      clearTimeout(timer);
      resolve();
    };
  });
}

export async function safePublish(
  client,
  destination,
  payload = {},
  headers = {}
) {
  try {
    await waitConnected(client, 8000); // chờ connect tối đa 8s
  } catch (err) {
    console.warn("Publish aborted: not connected", err);
    throw err;
  }
  // @stomp/stompjs client.publish API (modern)
  client.publish({ destination, body: JSON.stringify(payload), headers });
}

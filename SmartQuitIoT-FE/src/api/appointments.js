// src/api/appointments.js
import appointmentService from "@/services/appointmentService";

/**
 * Thin wrapper that unwraps GlobalResponse shape:
 * backend: { success, message, data, ... }
 * We return the data array / object or throw with message.
 */
const unwrap = (resp) => {
  if (!resp || !resp.data) throw new Error("Empty response");
  // If backend returned { success, message, data }
  const payload = resp.data;
  if (payload && Object.prototype.hasOwnProperty.call(payload, "data")) {
    return payload.data;
  }
  // fallback: maybe backend returned array directly
  if (Array.isArray(payload)) return payload;
  // otherwise return payload (object)
  return payload;
};

export const getUpcomingAppointments = async (opts = {}) => {
  const resp = await appointmentService.getUpcomingAppointments(opts);
  return unwrap(resp);
};

export const listCoachAppointments = async (opts = {}) => {
  const resp = await appointmentService.listCoachAppointments(opts);
  return unwrap(resp);
};

export const getAppointmentDetailForCoach = async (id) => {
  const resp = await appointmentService.getAppointmentDetailForCoach(id);
  return unwrap(resp);
};

export const cancelAppointmentByCoach = async (id) => {
  // This endpoint returns GlobalResponse with null data usually
  const resp = await appointmentService.cancelAppointmentByCoach(id);
  return unwrap(resp);
};

export const requestJoinToken = async (id) => {
  const resp = await appointmentService.requestJoinToken(id);
  return unwrap(resp);
};

export const completeAppointmentByCoach = async (id) => {
  const resp = await appointmentService.completeAppointmentByCoach(id);
  return unwrap(resp);
};

export const saveAppointmentSnapshots = async (id, imageUrls) => {
  const resp = await appointmentService.saveAppointmentSnapshots(id, imageUrls);
  return unwrap(resp);
};

export const getAppointmentSnapshots = async (id) => {
  const resp = await appointmentService.getAppointmentSnapshots(id);
  return unwrap(resp);
};

export default {
  getUpcomingAppointments,
  listCoachAppointments,
  getAppointmentDetailForCoach,
  cancelAppointmentByCoach,
  requestJoinToken,
  completeAppointmentByCoach,
  saveAppointmentSnapshots,
  getAppointmentSnapshots,
};

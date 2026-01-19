import { z } from "zod";

export const createCoach = z.object({
  username: z.string().min(1, "Username is required"),
  password: z.string().min(1, "Password is required"),
  confirmPassword: z.string().min(1, "Confirm Password is required"),
  email: z.string().email("Invalid email address"),
  firstName: z.string().min(1, "First name is required"),
  lastName: z.string().min(1, "Last name is required"),
  gender: z.enum(["MALE", "FEMALE", "OTHER"], "Gender is required"),
  certificateUrl: z.string(),
  experienceYears: z.string().min(1, "Experience years are required"),
  specializations: z.string().min(1, "Specializations are required"),
});

export const createCoachSchema = createCoach.refine(
  (data) => data.password === data.confirmPassword,
  { message: "Passwords do not match", path: ["confirmPassword"] }
);

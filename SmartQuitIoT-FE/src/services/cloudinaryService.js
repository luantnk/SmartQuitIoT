import axios from "axios";

const cloudinary_name = import.meta.env.VITE_CLOUDINARY_CLOUD_NAME;

export const uploadImage = async (body) => {
  return axios.post(
    `https://api.cloudinary.com/v1_1/${cloudinary_name}/image/upload`,
    body
  );
};

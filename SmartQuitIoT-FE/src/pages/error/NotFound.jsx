import { useNavigate } from "react-router-dom";
import notfound from "@/assets/404.jpg";

const NotFound = () => {
  const navigate = useNavigate();
  const notFoundUrl = notfound;
  return (
    <div
      className="boxShadow px-10 w-full lg:min-h-[957px] py-16 flex flex-col justify-center"
      style={{ background: `url(${notFoundUrl})`, backgroundSize: "cover" }}
    >
      <h1 className="text-[2rem] sm:text-[3rem] font-[600] text-white w-full lg:w-[50%]">
        Go Back , You’re Drunk!
      </h1>

      <button
        onClick={() => navigate(-1)}
        className="py-3 px-8 w-max rounded-full bg-[#92E3A9] hover:bg-[#4ec46f] text-white mt-5"
      >
        BACK
      </button>
    </div>
  );
};

export default NotFound;

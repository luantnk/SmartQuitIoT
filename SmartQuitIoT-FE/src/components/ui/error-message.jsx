import { InfoIcon } from "lucide-react";

const ErrorMessage = ({ text }) => {
  return (
    <div>
      <p className="text-red-500 text-sm">
        <InfoIcon className="inline mr-2 h-4 w-4" />
        {text}
      </p>
    </div>
  );
};

export default ErrorMessage;

import { signIn } from "next-auth/react";
import { FcGoogle } from "react-icons/fc";

const LoginPage = () => {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen gap-4 bg-gray-100">
      <h1 className="text-2xl font-bold">Authenticate yourself stranger</h1>
      <button
        onClick={() => signIn("google", { callbackUrl: "/admin/dashboard" })}
        className="flex items-center px-6 py-3 bg-white hover:bg-gray-100 rounded-md shadow-md gap-2"
      >
        <FcGoogle className="w-6 h-6" />
        <span className="text-gray-700 font-medium">Login with Google</span>
      </button>
    </div>
  );
};

export default LoginPage;

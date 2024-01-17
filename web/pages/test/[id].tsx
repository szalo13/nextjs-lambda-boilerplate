import { useRouter } from "next/router";

const DynamicPage = () => {
  const router = useRouter();
  const { id } = router.query; // Get the dynamic part of the URL

  return (
    <div>
      <h1>Dynamic Page</h1>
      <p>This is a dynamic page for ID: {id}</p>
    </div>
  );
};

export default DynamicPage;

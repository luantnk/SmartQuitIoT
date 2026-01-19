import React from "react";
import { ChevronRight, Home } from "lucide-react";
import { Link } from "react-router-dom";
import {
  Breadcrumb as BreadcrumbRoot,
  BreadcrumbEllipsis,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";

const AppBreadcrumb = ({ paths = [] }) => {
  const generatePath = (index) => {
    return (
      "/" +
      paths
        .slice(0, index + 1)
        .join("/")
        .toLowerCase()
    );
  };

  return (
    <BreadcrumbRoot className="mb-6">
      <BreadcrumbList>
        {/* Home Item */}
        <BreadcrumbItem>
          <BreadcrumbLink asChild>
            <Link to="/" className="flex items-center">
              <Home className="h-4 w-4" />
            </Link>
          </BreadcrumbLink>
        </BreadcrumbItem>

        {paths.length > 0 && <BreadcrumbSeparator />}

        {/* Path Items */}
        {paths.map((path, index) => {
          const isLast = index === paths.length - 1;
          const pathUrl = generatePath(index);

          return (
            <React.Fragment key={index}>
              <BreadcrumbItem>
                {isLast ? (
                  <BreadcrumbPage className="capitalize">{path}</BreadcrumbPage>
                ) : (
                  <BreadcrumbLink asChild>
                    <Link to={pathUrl} className="capitalize">
                      {path.replace(/-/g, " ")}
                    </Link>
                  </BreadcrumbLink>
                )}
              </BreadcrumbItem>
              {!isLast && <BreadcrumbSeparator />}
            </React.Fragment>
          );
        })}
      </BreadcrumbList>
    </BreadcrumbRoot>
  );
};

export default AppBreadcrumb;

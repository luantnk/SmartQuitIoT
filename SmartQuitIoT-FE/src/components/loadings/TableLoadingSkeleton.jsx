import React from "react";

const TableLoadingSkeleton = () => {
  return (
    <div className="min-h-screen bg-gray-50 p-8">
      {/* Header Section */}
      <div className="mb-8">
        {/* Breadcrumb Skeleton */}
        <div className="flex items-center gap-2 mb-4">
          <div className="h-4 w-8 bg-gray-200 rounded animate-pulse"></div>
          <div className="h-4 w-4 bg-gray-200 rounded animate-pulse"></div>
          <div className="h-4 w-16 bg-gray-200 rounded animate-pulse"></div>
          <div className="h-4 w-4 bg-gray-200 rounded animate-pulse"></div>
          <div className="h-4 w-24 bg-gray-200 rounded animate-pulse"></div>
        </div>
      </div>

      {/* Search and Sort Section */}
      <div className="bg-white rounded-lg shadow mb-4 p-4">
        <div className="flex items-center justify-between">
          <div className="flex-1 max-w-md">
            <div className="h-10 w-full bg-gray-200 rounded animate-pulse"></div>
          </div>
          <div className="h-6 w-24 bg-gray-200 rounded animate-pulse ml-4"></div>
        </div>
      </div>

      {/* Table Section */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        {/* Table Header */}
        <div className="grid grid-cols-12 gap-4 p-4 border-b border-gray-200 bg-gray-50">
          <div className="col-span-1">
            <div className="h-4 w-8 bg-gray-300 rounded animate-pulse"></div>
          </div>
          <div className="col-span-5">
            <div className="h-4 w-12 bg-gray-300 rounded animate-pulse"></div>
          </div>
          <div className="col-span-3">
            <div className="h-4 w-16 bg-gray-300 rounded animate-pulse"></div>
          </div>
          <div className="col-span-3">
            <div className="h-4 w-24 bg-gray-300 rounded animate-pulse"></div>
          </div>
        </div>

        {/* Table Rows Skeleton */}
        {[...Array(5)].map((_, index) => (
          <div
            key={index}
            className="grid grid-cols-12 gap-4 p-4 border-b border-gray-100 hover:bg-gray-50"
            style={{ animationDelay: `${index * 100}ms` }}
          >
            <div className="col-span-1 flex items-center">
              <div className="h-4 w-12 bg-gray-200 rounded animate-pulse"></div>
            </div>
            <div className="col-span-5 flex items-center">
              <div className="h-4 w-full bg-gray-200 rounded animate-pulse"></div>
            </div>
            <div className="col-span-3 flex items-center">
              <div className="h-6 w-20 bg-gray-200 rounded-full animate-pulse"></div>
            </div>
            <div className="col-span-3 flex items-center">
              <div className="h-4 w-32 bg-gray-200 rounded animate-pulse"></div>
            </div>
          </div>
        ))}

        {/* Empty State Alternative (commented out - use this when showing "No results") */}
        {/* <div className="p-16 text-center">
          <div className="flex justify-center mb-4">
            <div className="h-16 w-16 bg-gray-200 rounded animate-pulse"></div>
          </div>
          <div className="h-4 w-32 bg-gray-200 rounded animate-pulse mx-auto"></div>
        </div> */}
      </div>
    </div>
  );
};

export default TableLoadingSkeleton;

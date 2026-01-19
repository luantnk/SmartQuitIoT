import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { ArrowUpDown, Search } from "lucide-react";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const SearchBar = ({
  placeholderText,
  searchString,
  setSearchString,
  sortBy,
  setSortBy,
  filterBy,
  setFilterBy,
  filterBySubscriptionStatus,
  setFilterBySubscriptionStatus,
  filterByAppointmentStatus,
  setFilterByAppointmentStatus,
}) => {
  return (
    <div className="flex flex-col md:flex-row gap-4">
      {/* Search */}
      {searchString !== undefined && setSearchString ? (
        <div className="flex-1">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
            <Input
              type="text"
              placeholder={placeholderText || "Search..."}
              value={searchString}
              onChange={(e) => setSearchString(e.target.value)}
              className="pl-10"
            />
          </div>
        </div>
      ) : null}

      {sortBy ? (
        <Button
          variant="outline"
          onClick={() => setSortBy(sortBy === "ASC" ? "DESC" : "ASC")}
          className="flex items-center gap-2"
        >
          <ArrowUpDown className="h-4 w-4" />
          Sort by ID {sortBy === "ASC" ? "↑" : "↓"}
        </Button>
      ) : (
        <></>
      )}
      {/* Sort */}

      {filterBy !== undefined ? (
        <Select
          value={
            filterBy === true ? "true" : filterBy === false ? "false" : "all"
          }
          onValueChange={(val) => {
            if (val === "all") return setFilterBy(undefined); // or null if you prefer
            setFilterBy(val === "true");
          }}
        >
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectLabel>Status</SelectLabel>
              <SelectItem value="true">Active</SelectItem>
              <SelectItem value="false">Deleted</SelectItem>
            </SelectGroup>
          </SelectContent>
        </Select>
      ) : (
        <></>
      )}
      {filterBySubscriptionStatus !== undefined ? (
        <Select
          value={filterBySubscriptionStatus || "all"}
          onValueChange={(val) => {
            if (val === "all") return setFilterBySubscriptionStatus("");
            setFilterBySubscriptionStatus(val);
          }}
        >
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectLabel>Status</SelectLabel>
              <SelectItem value="all">All</SelectItem>
              <SelectItem value="AVAILABLE">Available</SelectItem>
              <SelectItem value="EXPIRED">Expired</SelectItem>
              <SelectItem value="UNAVAILABLE">Unavailable</SelectItem>
            </SelectGroup>
          </SelectContent>
        </Select>
      ) : (
        <></>
      )}
      {filterByAppointmentStatus !== undefined ? (
        <Select
          value={filterByAppointmentStatus || "all"}
          onValueChange={(val) => {
            if (val === "all") return setFilterByAppointmentStatus("");
            setFilterByAppointmentStatus(val);
          }}
        >
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Status" />
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectLabel>Status</SelectLabel>
              <SelectItem value="all">All</SelectItem>
              <SelectItem value="PENDING">Pending</SelectItem>
              <SelectItem value="IN_PROGRESS">In Progres</SelectItem>
              <SelectItem value="COMPLETED">Completed</SelectItem>
              <SelectItem value="CANCELLED">Cancelled</SelectItem>
            </SelectGroup>
          </SelectContent>
        </Select>
      ) : (
        <></>
      )}
    </div>
  );
};

export default SearchBar;

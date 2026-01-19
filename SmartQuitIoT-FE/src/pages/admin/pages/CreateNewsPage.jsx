import { useForm } from "react-hook-form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { X, Upload } from "lucide-react";
import { useState } from "react";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
const CreateNewsPage = () => {
  const [media, setMedia] = useState([]);
  const [status, setStatus] = useState(["DRAFT", "PUBLISHED"]);
  const [previewImages, setPreviewImages] = useState([]);

  const form = useForm({
    defaultValues: {
      title: "",
      content: "",
      status: "DRAFT",
    },
  });

  const handleImageChange = (e) => {
    const files = Array.from(e.target.files);
    setImages(files);

    const imagesUrl = files.map((file) => URL.createObjectURL(file));
    setPreviewImages(imagesUrl);

    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (event) => {
        const url = event.target?.result;
        const mediaType = file.type.startsWith("video") ? "video" : "image";
        setMedia((prev) => [
          ...prev,
          {
            id: Date.now().toString(),
            type: mediaType,
            url,
            caption: "",
          },
        ]);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleFormSubmit = (data) => {
    console.log(data);
  };

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-news", "create-news"]} />
      <Form {...form}>
        <form
          onSubmit={form.handleSubmit(handleFormSubmit)}
          className="space-y-6"
        >
          {/* Title */}
          <FormField
            control={form.control}
            name="title"
            rules={{ required: "Title is required" }}
            render={({ field }) => (
              <FormItem>
                <FormLabel>Title *</FormLabel>
                <FormControl>
                  <Input placeholder="Article title" {...field} />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Status */}
          <FormField
            control={form.control}
            name="status"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Status *</FormLabel>
                <FormControl>
                  <Select>
                    <SelectTrigger className="w-[180px]">
                      <SelectValue placeholder="Status" />
                    </SelectTrigger>
                    <SelectContent>
                      {status.map((statusOption) => (
                        <SelectItem
                          key={statusOption}
                          value={statusOption.toLowerCase()}
                        >
                          {statusOption}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Content */}
          <FormField
            control={form.control}
            name="content"
            rules={{ required: "Content is required" }}
            render={({ field }) => (
              <FormItem>
                <FormLabel>Content *</FormLabel>
                <FormControl>
                  <textarea
                    placeholder="Full article content"
                    rows={6}
                    className="w-full px-3 py-2 border border-input rounded-md bg-background text-foreground resize-none"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {/* Media Section */}
          <div className="border-t border-border pt-4">
            <FormLabel className="block mb-3">
              Media (Photos & Videos)
            </FormLabel>
            <div className="mb-4">
              <label className="flex items-center justify-center w-full px-4 py-6 border-2 border-dashed border-border rounded-lg cursor-pointer hover:bg-muted/50 transition-colors">
                <div className="flex flex-col items-center justify-center">
                  <Upload className="w-6 h-6 text-muted-foreground mb-2" />
                  <span className="text-sm text-muted-foreground">
                    Click to upload or drag and drop
                  </span>
                  <span className="text-xs text-muted-foreground mt-1">
                    PNG, JPG, MP4, WebM up to 50MB
                  </span>
                </div>
                <input
                  type="file"
                  accept="image/*,video/*"
                  onChange={handleImageChange}
                  className="hidden"
                />
              </label>
            </div>

            <div className="mt-4 flex space-x-4 overflow-x-auto p-2 border border-gray-200 rounded-lg shadow-inner">
              {previewImages.length > 0 ? (
                previewImages.map((url) => (
                  <img
                    key={url}
                    src={url}
                    alt="Product preview"
                    className="w-32 h-32 object-cover rounded-lg border border-gray-300 shadow-sm hover:shadow-md transition-shadow duration-200 ease-in-out cursor-pointer"
                  />
                ))
              ) : (
                <p className="text-gray-500 italic">No images selected</p>
              )}
            </div>
          </div>

          {/* Form Actions */}
          <div className="flex gap-3 justify-end pt-4">
            <Button
              type="button"
              variant="outline"
              onClick={() => form.reset()}
            >
              Cancel
            </Button>
            <Button
              type="submit"
              className="bg-primary text-primary-foreground hover:bg-primary/90"
            >
              Create News
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
};

export default CreateNewsPage;

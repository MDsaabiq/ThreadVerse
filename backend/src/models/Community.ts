import { Schema, model, Types } from "mongoose";

const communitySchema = new Schema(
  {
    name: { type: String, required: true, unique: true, index: true },
    description: { type: String, default: "" },
    createdBy: { type: Types.ObjectId, ref: "User", required: true },
    isPrivate: { type: Boolean, default: false },
    isNsfw: { type: Boolean, default: false },
    allowedPostTypes: {
      type: [String],
      default: ["text", "link", "image", "poll"],
    },
    memberCount: { type: Number, default: 1 },
    moderators: [{ type: Types.ObjectId, ref: "User" }],
    rules: [{ type: String }],
    iconUrl: { type: String },
    bannerUrl: { type: String },
  },
  { timestamps: true }
);

export const Community = model("Community", communitySchema);

import { Schema, model, Types } from "mongoose";

const joinRequestSchema = new Schema(
  {
    userId: { type: Types.ObjectId, ref: "User", required: true, index: true },
    communityId: {
      type: Types.ObjectId,
      ref: "Community",
      required: true,
      index: true,
    },
    status: {
      type: String,
      enum: ["pending", "approved", "rejected"],
      default: "pending",
    },
    message: { type: String },
  },
  { timestamps: true }
);

joinRequestSchema.index({ userId: 1, communityId: 1 }, { unique: true });
joinRequestSchema.index({ communityId: 1, status: 1 });

export const JoinRequest = model("JoinRequest", joinRequestSchema);

import { Schema, model, Types } from "mongoose";

const membershipSchema = new Schema(
  {
    userId: { type: Types.ObjectId, ref: "User", required: true, index: true },
    communityId: {
      type: Types.ObjectId,
      ref: "Community",
      required: true,
      index: true,
    },
    role: { type: String, enum: ["member", "moderator", "owner"], default: "member" },
  },
  { timestamps: true }
);

membershipSchema.index({ userId: 1, communityId: 1 }, { unique: true });

export const Membership = model("Membership", membershipSchema);

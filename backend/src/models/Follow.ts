import { Schema, model, Types } from "mongoose";

const followSchema = new Schema(
  {
    followerId: { type: Types.ObjectId, ref: "User", required: true, index: true },
    followingId: { type: Types.ObjectId, ref: "User", required: true, index: true },
  },
  { timestamps: true }
);

// Ensure a user can only follow another user once
followSchema.index({ followerId: 1, followingId: 1 }, { unique: true });

export type FollowDocument = typeof followSchema extends infer S
  ? S extends Schema<infer T>
    ? T & { _id: Types.ObjectId }
    : never
  : never;

export const Follow = model("Follow", followSchema);

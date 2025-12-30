import { Schema, model, Types } from "mongoose";

const userSchema = new Schema(
  {
    username: { type: String, required: true, unique: true, index: true },
    email: { type: String, required: true, unique: true },
    passwordHash: { type: String, required: true },
    displayName: { type: String },
    bio: { type: String, default: "" },
    avatarUrl: { type: String },
    karma: {
      post: { type: Number, default: 0 },
      comment: { type: Number, default: 0 },
    },
    followersCount: { type: Number, default: 0 },
    followingCount: { type: Number, default: 0 },
    roles: [{ type: String }],
    modCommunities: [{ type: Types.ObjectId, ref: "Community" }],
  },
  { timestamps: true }
);

export type UserDocument = typeof userSchema extends infer S
  ? S extends Schema<infer T>
    ? T & { _id: Types.ObjectId }
    : never
  : never;

export const User = model("User", userSchema);

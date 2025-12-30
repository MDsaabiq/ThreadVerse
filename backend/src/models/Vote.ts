import { Schema, model, Types } from "mongoose";

const voteSchema = new Schema(
  {
    userId: { type: Types.ObjectId, ref: "User", required: true, index: true },
    targetType: { type: String, enum: ["post", "comment"], required: true },
    targetId: { type: Types.ObjectId, required: true, index: true },
    value: { type: Number, enum: [1, -1], required: true },
  },
  { timestamps: true }
);

voteSchema.index({ userId: 1, targetType: 1, targetId: 1 }, { unique: true });

export const Vote = model("Vote", voteSchema);

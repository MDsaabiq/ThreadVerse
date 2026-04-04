import { Schema, model, Types } from "mongoose";

const pollVoteSchema = new Schema(
  {
    userId: { type: Types.ObjectId, ref: "User", required: true, index: true },
    postId: { type: Types.ObjectId, ref: "Post", required: true, index: true },
    optionId: { type: String, required: true },
  },
  { timestamps: true }
);

pollVoteSchema.index({ userId: 1, postId: 1 }, { unique: true });

export const PollVote = model("PollVote", pollVoteSchema);
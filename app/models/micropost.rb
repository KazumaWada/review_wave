class Micropost < ApplicationRecord
  belongs_to :user #->user.micropost.create
  enum status: { draft:0, published:1 }#@post.draftで取得可
  default_scope -> {order(created_at: :desc)}#新しい順にmicropostを表示
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 1000}

  #inputは英語のみ
  #validates :content, presence: true, format: {with: /\A[a-zA-Z\s]+\z/, message: "English please 😗"}
end

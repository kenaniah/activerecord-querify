Author.create name: "First author"
Author.create name: "Second author"

Post.create name: "First post", author_id: 1
Post.create name: "Second post", author_id: 1
Post.create name: "Third post", author_id: 1
Post.create name: "Fourth post", author_id: 2

Comment.create author_id: 1, post_id: 1, comment: "First comment"
Comment.create author_id: 2, post_id: 1, comment: "Second comment"
Comment.create author_id: 1, post_id: 2, comment: "Third comment"
Comment.create author_id: 1, post_id: 2, comment: "Fourth comment"
Comment.create author_id: 2, post_id: 3, comment: "Fifth comment"
Comment.create author_id: 2, post_id: 4, comment: "Sixth comment"
Comment.create author_id: 1, post_id: 1, comment: "Seventh comment"
Comment.create author_id: 2, post_id: 1, comment: "Eigth comment"
Comment.create author_id: 1, post_id: 1, comment: "Ninth comment"

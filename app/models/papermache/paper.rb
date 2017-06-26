class Papermache::Paper < ActiveRecord::Base

  self.table_name = "papers"

  validates :file, :title, presence: true

  belongs_to :account

  mount_uploader :file, FileUploader

  acts_as_taggable

  acts_as_votable

  # Search
  
  include PgSearch
  pg_search_scope :search, 
                  against: [:title, :themes, :about],
                  using: { tsearch: { dictionary: 'english' } },
                  associated_against: { 
                    account: [:first_name, :last_name],
                    tags: :name
                  },
                  ignoring: :accents

  def sma
    result = ActiveRecord::Base.connection.execute("SELECT GET_PAPER_SMA(#{self.id});")
    return result.getvalue(0,0)
  end
end

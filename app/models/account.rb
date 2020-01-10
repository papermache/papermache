require 'pg'

class Account < ActiveRecord::Base

  acts_as_votable
    
  acts_as_follower
  acts_as_followable

  # Search
  
  include PgSearch
  pg_search_scope :search, 
                  against: [:first_name, :last_name, :edu_email],
                  using: {
                    tsearch: { dictionary: 'english' }
                  }

  # Associations
  
  belongs_to :student, dependent: :delete
 
  has_many :account_majors
  has_many :majors, through: :account_majors

  has_many :account_minors
  has_many :minors, through: :account_minors

  has_many :research_interests, dependent: :destroy
  accepts_nested_attributes_for :research_interests, reject_if: :all_blank, allow_destroy: true

  has_many :papers, dependent: :destroy, :class_name => '::Papermache::Paper'
  accepts_nested_attributes_for :papers, reject_if: :all_blank, allow_destroy: true 

  # Validations
  validates :first_name, :last_name, presence: true
  validate :two_majors_or_minors_only

  # .edu email validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.edu/i
  validates :edu_email, format: { with: VALID_EMAIL_REGEX }

  mount_uploader :avatar, ImageUploader

  def full_name
    return self.first_name + ' ' + self.last_name
  end

  # is creating account completed?
  def completed?
    # self.first_name.present? and self.last_name.present? and self.edu_email.present?
    self.valid?
  end

  def two_majors_or_minors_only
    if self.majors.length > 2 
      errors[:base] << 'Please choose up to two majors'
    elsif self.minors.length > 2
      errors[:base] << 'Please choose up to two minors'
    end
  end

  def quantified_reputation
    result = ActiveRecord::Base.connection.exec_query("SELECT GET_REPUTATION(#{self.id});")
    return result.rows[0][0].to_d.truncate(2).to_s
  end

  def allpaper_received_votes
    result = ActiveRecord::Base.connection.exec_query("SELECT GET_VOTES_SCORE(#{self.id});")
    return result.rows[0][0]  
  end

  def uploaded_paper_cnt
    self.papers.count
  end

  def voted_papers_cnt
    result = ActiveRecord::Base.connection.exec_query("SELECT GET_VOTED_PAPER_CNT(#{self.student_id});")
    return result.rows[0][0] 
  end

  def voted_papers
    voted_papers = Papermache::Paper.find_by_sql ["select * from get_voted_papers(:account_id)", { :account_id => self.id } ]
  end

  def gain_losses_paper(paper_id)
    result = ActiveRecord::Base.connection.exec_query("SELECT GET_GAIN_LOSSES_PAPER(#{paper_id}, #{self.id});")
    return result.rows[0][0].to_d.truncate(2).to_s 
  end

  def vote_cast_for(paper_id)
    result = ActiveRecord::Base.connection.exec_query("SELECT GET_VOTE_CAST(#{paper_id}, #{self.id});")
    return result.rows[0][0] 
  end

  def gain_losses_all
    result = ActiveRecord::Base.connection.exec_query("SELECT GET_GAIN_LOSSES(#{self.id});")
    return result.rows[0][0].to_d.truncate(2).to_s     
  end
end

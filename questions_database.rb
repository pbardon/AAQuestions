require           'singleton'
require           'sqlite3'
require_relative  'user'
require_relative  'question'
require_relative  'reply'
require_relative  'question_like'
require_relative  'question_follower'

class QuestionsDatabase < SQLite3::Database

  include Singleton

  def initialize
    super('qs.db')
    
    self.results_as_hash = true
    self.type_translation = true
  end
  
end
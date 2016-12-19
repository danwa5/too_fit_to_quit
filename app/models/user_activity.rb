class UserActivity < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity, polymorphic: true

  validates :user, presence: true
  validates :uid, presence: true

  scope :monthly_breakdown, ->(year=Date.today.year) {
    find_by_sql("
      select * from (select * from generate_series(1,12) month) month
      left join (
        select extract(month from start_time) as month, count(id) as total_#{year-1}
        from user_activities
        where activity_type = 'Activity::FitbitRun' and date_part('year', start_time) = #{year-1}
        group by month
      ) ua using (month)
      left join (
        select extract(month from start_time) as month, count(id) as total_#{year}
        from user_activities
        where activity_type = 'Activity::FitbitRun' and date_part('year', start_time) = #{year}
        group by month
      ) ua2 using (month)
      order by month;"
    ).as_json
  }
end

# -*- coding: utf-8 -*-
class Record < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :habit_id, :recorddata_id, :value
end

require 'test_helper'

class ZafuTemplateTest < Zena::View::TestCase
  
  context 'Without a logged in user' do
    setup do
      login(:anon)
      visiting(:status)
    end
    
    should 'receive page_numbers' do
      s = ""
      page_numbers(2, 3, ',') {|p,j| s << "#{j}#{p}"}
      assert_equal "1,2,3", s
      s = ""
      page_numbers(2, 30, ',') {|p,j| s << "#{j}#{p}"}
      assert_equal "1,2,3,4,5,6,7,8,9,10", s
      s = ""
      page_numbers(14, 30, ',') {|p,j| s << "#{j}#{p}"}
      assert_equal "10,11,12,13,14,15,16,17,18,19", s
      s = ""
      page_numbers(28, 30, ' | ') {|p,j| s << "#{j}#{p}"}
      assert_equal "21 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | 29 | 30", s
    end 
  end # Without a logged in user
end
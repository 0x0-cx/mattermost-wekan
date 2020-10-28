# frozen_string_literal: true

class MockArray < Array
  def sort(*)
    [{ 'sort' => -10 }]
  end
end

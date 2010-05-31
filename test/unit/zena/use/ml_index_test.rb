require 'test_helper'

class EnrollableTest < Zena::Unit::TestCase
  class NodeStringIndex < ActiveRecord::Base
    set_table_name :idx_string_nodes
  end

  class NodeMLStringIndex < ActiveRecord::Base
    set_table_name :idx_ml_string_nodes
  end

  context 'A visitor with write access' do
    setup do
      login(:tiger)
    end

    context 'creating a node' do
      # Node has 'title' as multilingual index
      subject do
        secure(Node) { Node.create(
          :title     => 'Piksel',
          :parent_id => nodes_id(:cleanWater)
        )}
      end

      should 'write index for every language available' do
        assert_difference('NodeMLStringIndex.count', 4) do
          subject
        end
      end

      context 'with non ML indices' do
        subject do
          k = Class.new(Node) do
            property.string 'foo', :index => true
          end
          secure(k) { k.create(
            :title     => 'Zanzibar',
            :foo       => 'bar',
            :parent_id => nodes_id(:cleanWater)
          )}
        end

        should 'insert single value' do
          assert_difference('NodeStringIndex.count', 1) do
            # title = 4, name = 1
            assert subject
          end
        end
      end # with non ML indices

    end # creating a node

    context 'updating a node' do
      setup do
        visitor.lang = 'fr'
      end

      subject do
        secure(Node) { nodes(:news) }
      end

      should 'write index for concerned language only' do
        assert_difference('NodeMLStringIndex.count', 1) do
          subject.update_attributes('title' => 'Nouvelles')
        end
      end
    end # updating a node

  end # A visitor with write access
end

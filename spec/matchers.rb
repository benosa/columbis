require "timeout"

module Matchers
  extend RSpec::Matchers::DSL

  matcher :become_true do
    match do |block|
      begin
        Timeout.timeout(Capybara.default_wait_time) do
          sleep(0.1) until value = block.call
          value
        end
      rescue TimeoutError
        false
      end
    end
  end

  matcher :not_be_able_to do |ability_array, target|
    match do |ability|
      @ability_hash = ability_array
      if @ability_hash == :manage
        @ability_hash = [:read, :edit, :update, :destroy]
      end
      @ability_hash.map!{|action| {action => ability.can?(action, target)}}
      !@ability_hash.any?{|element| element.to_a[1] == true}
    end

    failure_message_for_should do |ability|
      message = "expected ability:#{ability} to have ability: for #{target}, but actual result is #{@ability_hash}"
    end
  end
end
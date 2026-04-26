module Searchable
  extend ActiveSupport::Concern

  SEARCH_TERM_LIMIT = 255

  class_methods do
    def search(query)
      return all if query.blank?

      sanitized = sanitize_search_term(query)
      term = "%#{sanitized}%"

      where(search_conditions, *Array.new(searchable_attributes.size, term))
    end

    def search_by(*attributes)
      @searchable_attributes = attributes.map(&:to_s)
    end

    def searchable_attributes
      @searchable_attributes || []
    end

    private

      def search_conditions
        searchable_attributes.map { |attr| "#{table_name}.#{attr} LIKE ?" }.join(" OR ")
      end

      def sanitize_search_term(term)
        term.to_s.strip.truncate(SEARCH_TERM_LIMIT, omission: "").gsub(/[%_]/, '\\\\\0')
      end
  end
end

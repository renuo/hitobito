# frozen_string_literal: true

#  Copyright (c) 2026, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe Event::LogController do
  let(:person) { people(:top_leader) }
  let(:event) { events(:top_course) }

  describe "GET index", versioning: true do
    before do
      sign_in(person)

      # create some versions
      event.save!
      event.update!(name: "some new name")
      event.dates.first.update!(label: "some new date label")
      event.update!(description: "boring desciption, no one will read")
    end

    it "fetches papertrail versions of event" do
      get :index, params: {group_id: event.groups.first.id, id: event.id}

      versions = assigns(:versions)

      expect(versions.size).to eq(4)
    end
  end

  describe "GET index with a deleted question translation", versioning: true do
    render_views

    before do
      sign_in(person)

      # create an "update" version on the question's translation, then remove the
      # question so the translation the version points to no longer exists.
      question = Fabricate(:event_question, event: event, question: "Wie alt bist du?")
      question.update!(question: "Wie alt bist du wirklich?")
      question.destroy!
    end

    it "does not raise when the translation version's item has been deleted" do
      expect {
        get :index, params: {group_id: event.groups.first.id, id: event.id}
      }.not_to raise_error
    end
  end
end

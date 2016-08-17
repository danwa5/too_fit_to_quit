require 'rails_helper'

RSpec.describe ImportsController, type: :controller do
  login_user

  it 'must have a current_user' do
    expect(subject.current_user).to_not eq(nil)
  end

  describe 'POST create' do
    context 'without import_date parameter' do
      subject { post :create }

      it 'must not enqueue Fitbit::FindActivityWorker' do
        expect { subject }.not_to change(Fitbit::FindActivityWorker.jobs, :count)
      end
      it 'must not enqueue Strava::FindActivityWorker' do
        expect { subject }.not_to change(Strava::FindActivityWorker.jobs, :count)
      end
    end

    context 'without correctly formatted import_date parameter' do
      subject { post :create, import_date: '123' }

      it 'must not enqueue Fitbit::FindActivityWorker' do
        expect { subject }.not_to change(Fitbit::FindActivityWorker.jobs, :count)
      end
      it 'must not enqueue Strava::FindActivityWorker' do
        expect { subject }.not_to change(Strava::FindActivityWorker.jobs, :count)
      end
    end

    context 'with correctly formatted import_date parameter' do
      subject { post :create, import_date: Date.today.strftime('%Y-%m-%d') }

      it 'must enqueue Fitbit::FindActivityWorker' do
        expect { subject }.to change(Fitbit::FindActivityWorker.jobs, :count).by(1)
      end
      it 'must enqueue Strava::FindActivityWorker' do
        expect { subject }.to change(Strava::FindActivityWorker.jobs, :count).by(1)
      end
      it 'must redirect to /runs' do
        expect(subject).to redirect_to(runs_path)
      end
    end
  end
end

class GithostingShellWorker
  include Sidekiq::Worker

  sidekiq_options queue: :redmine_git_hosting, retry: false

  def self.maybe_do(command, object, options = {})
    Sidekiq::Queue.new(:redmine_git_hosting).each |job|
      return nil if job.args == [command, object, options]
    end

    perform_async(command, object, options)
  end

  def perform(command, object, options = {})
    logger.info("#{command} | #{object} | #{options}")
    RedmineGitHosting::GitoliteWrapper.resync_gitolite(command, object, options)
  end
end

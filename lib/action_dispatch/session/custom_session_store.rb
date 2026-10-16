module ActionDispatch
  module Session
    class CustomSessionStore < ActionDispatch::Session::AbstractStore

      def initialize(app, options = {})
        @cache = options[:cache] || Rails.cache
        options[:expire_after] ||= @cache.options[:expires_in]
        super
      end

      def find_session(env, sid)
          session = get_session_with_fallback(env,sid)
          sid =  cache_key(env)
          [sid, session]
      end

      def write_session(env, sid, session, options)
        key = cache_key(env)
        if session
          @cache.write(key, session, expires_in: options[:expire_after])
        else
          @cache.delete(key)
        end
        sid = cache_key(env)
        sid
      end

      def delete_session(env, sid, options)
        @cache.delete(cache_key(env))
        generate_sid
      end

      private

        def cache_key(env)
          env.remote_ip.present? ? env.remote_ip : 'temp-key'
        end

        def get_session_with_fallback(env, sid)
          @cache.read(cache_key(env))
        end
    end
  end
end
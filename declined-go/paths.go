package declined

const (
	PathEvents     = "/v1/events"
	PathCustomers  = "/v1/customers"
	PathRecoveries = "/v1/recoveries"
	PathSequences  = "/v1/sequences"
	PathWebhooks   = "/v1/webhooks"
	PathAnalytics  = "/v1/analytics"
	PathIncentives = "/v1/incentives"

	DefaultBaseURL = "https://api.declined.io/api"
)

func RecoveryMarkRecoveredPath(id string) string {
	return "/v1/recoveries/" + id + "/mark-recovered"
}

func buildURL(baseURL, path string) string {
	if len(baseURL) > 0 && baseURL[len(baseURL)-1] == '/' {
		return baseURL[:len(baseURL)-1] + path
	}
	return baseURL + path
}

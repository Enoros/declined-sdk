package declined_test

import (
	"context"
	"io"
	"net/http"
	"strings"
	"testing"

	declined "github.com/Enoros/declined-sdk/declined-go"
)

const apiKey = "decl_live_sk_test_key"

type roundTripper func(*http.Request) (*http.Response, error)

func (f roundTripper) RoundTrip(req *http.Request) (*http.Response, error) {
	return f(req)
}

func TestClientEndpoints(t *testing.T) {
	cases := []struct {
		name   string
		method string
		path   string
		call   func(*declined.Client) error
	}{
		{
			name: "POST /v1/events", method: http.MethodPost, path: declined.PathEvents,
			call: func(c *declined.Client) error {
				_, err := c.Events.Create(context.Background(), declined.EventCreateParams{
					EventID: "evt_1", Type: "payment_failed", CustomerID: "cus_1",
				})
				return err
			},
		},
		{name: "GET /v1/customers", method: http.MethodGet, path: declined.PathCustomers, call: func(c *declined.Client) error {
			_, err := c.Customers.List(context.Background(), nil)
			return err
		}},
		{name: "GET /v1/recoveries", method: http.MethodGet, path: declined.PathRecoveries, call: func(c *declined.Client) error {
			_, err := c.Recoveries.List(context.Background(), nil)
			return err
		}},
		{name: "GET /v1/sequences", method: http.MethodGet, path: declined.PathSequences, call: func(c *declined.Client) error {
			_, err := c.Sequences.List(context.Background(), nil)
			return err
		}},
		{name: "GET /v1/webhooks", method: http.MethodGet, path: declined.PathWebhooks, call: func(c *declined.Client) error {
			_, err := c.Webhooks.List(context.Background(), nil)
			return err
		}},
		{name: "GET /v1/incentives", method: http.MethodGet, path: declined.PathIncentives, call: func(c *declined.Client) error {
			_, err := c.Incentives.List(context.Background(), nil)
			return err
		}},
		{name: "GET /v1/analytics", method: http.MethodGet, path: declined.PathAnalytics, call: func(c *declined.Client) error {
			_, err := c.Analytics.Get(context.Background(), nil)
			return err
		}},
		{
			name: "POST /v1/events payment_recovered", method: http.MethodPost, path: declined.PathEvents,
			call: func(c *declined.Client) error {
				_, err := c.Events.MarkPaymentRecovered(context.Background(), declined.EventCreateParams{
					EventID: "evt_2", CustomerID: "cus_1", InvoiceID: "inv_1",
				})
				return err
			},
		},
		{
			name: "POST /v1/recoveries/:id/mark-recovered", method: http.MethodPost, path: declined.RecoveryMarkRecoveredPath("ra_123"),
			call: func(c *declined.Client) error {
				_, err := c.Recoveries.MarkRecovered(context.Background(), "ra_123")
				return err
			},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			httpClient := &http.Client{Transport: roundTripper(func(req *http.Request) (*http.Response, error) {
				want := declined.DefaultBaseURL + tc.path
				if req.URL.String() != want {
					t.Fatalf("url = %q, want %q", req.URL.String(), want)
				}
				if req.Method != tc.method {
					t.Fatalf("method = %q, want %q", req.Method, tc.method)
				}
				if got := req.Header.Get("Authorization"); got != "Bearer "+apiKey {
					t.Fatalf("auth = %q", got)
				}
				return &http.Response{
					StatusCode: 200,
					Body:       io.NopCloser(strings.NewReader(`{"data":[],"has_more":false}`)),
					Header:     http.Header{"Content-Type": []string{"application/json"}},
				}, nil
			})}

			client := declined.New(apiKey, declined.WithHTTPClient(httpClient))
			if err := tc.call(client); err != nil {
				t.Fatalf("call failed: %v", err)
			}
		})
	}
}

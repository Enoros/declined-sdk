package declined

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
)

type Error struct {
	Status  int
	Code    string
	Message string
}

func (e *Error) Error() string {
	return e.Message
}

type Client struct {
	apiKey  string
	baseURL string
	http    *http.Client

	Events     EventsService
	Customers  CustomersService
	Recoveries RecoveriesService
	Sequences  SequencesService
	Webhooks   WebhooksService
	Incentives IncentivesService
	Analytics  AnalyticsService
}

type Option func(*Client)

func WithBaseURL(baseURL string) Option {
	return func(c *Client) { c.baseURL = baseURL }
}

func WithHTTPClient(httpClient *http.Client) Option {
	return func(c *Client) { c.http = httpClient }
}

func New(apiKey string, opts ...Option) *Client {
	c := &Client{
		apiKey:  apiKey,
		baseURL: DefaultBaseURL,
		http:    http.DefaultClient,
	}
	for _, opt := range opts {
		opt(c)
	}
	c.Events = EventsService{client: c}
	c.Customers = CustomersService{client: c, path: PathCustomers}
	c.Recoveries = RecoveriesService{client: c, path: PathRecoveries}
	c.Sequences = SequencesService{client: c, path: PathSequences}
	c.Webhooks = WebhooksService{client: c, path: PathWebhooks}
	c.Incentives = IncentivesService{client: c, path: PathIncentives}
	c.Analytics = AnalyticsService{client: c, path: PathAnalytics}
	return c
}

func (c *Client) request(ctx context.Context, method, path string, body any, params url.Values) ([]byte, error) {
	u := buildURL(c.baseURL, path)
	if len(params) > 0 {
		u = u + "?" + params.Encode()
	}

	var reader io.Reader
	if body != nil {
		b, err := json.Marshal(body)
		if err != nil {
			return nil, err
		}
		reader = bytes.NewReader(b)
	}

	req, err := http.NewRequestWithContext(ctx, method, u, reader)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+c.apiKey)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")

	resp, err := c.http.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode >= 400 {
		var payload struct {
			Error struct {
				Code    string `json:"code"`
				Message string `json:"message"`
			} `json:"error"`
		}
		_ = json.Unmarshal(data, &payload)
		msg := payload.Error.Message
		if msg == "" {
			msg = fmt.Sprintf("request failed with status %d", resp.StatusCode)
		}
		return nil, &Error{Status: resp.StatusCode, Code: payload.Error.Code, Message: msg}
	}

	return data, nil
}

type ListParams struct {
	Limit         *int
	StartingAfter *string
}

func (p *ListParams) values() url.Values {
	v := url.Values{}
	if p == nil {
		return v
	}
	if p.Limit != nil {
		v.Set("limit", fmt.Sprintf("%d", *p.Limit))
	}
	if p.StartingAfter != nil {
		v.Set("starting_after", *p.StartingAfter)
	}
	return v
}

type EventCreateParams struct {
	EventID    string         `json:"event_id"`
	Type       string         `json:"type"`
	CustomerID string         `json:"customer_id"`
	InvoiceID  string         `json:"invoice_id,omitempty"`
	Amount     int            `json:"amount,omitempty"`
	Currency   string         `json:"currency,omitempty"`
	Provider   string         `json:"provider,omitempty"`
	Metadata   map[string]any `json:"metadata,omitempty"`
}

type EventsService struct{ client *Client }

func (s EventsService) Create(ctx context.Context, params EventCreateParams) (map[string]any, error) {
	data, err := s.client.request(ctx, http.MethodPost, PathEvents, params, nil)
	if err != nil {
		return nil, err
	}
	var out map[string]any
	return out, json.Unmarshal(data, &out)
}

func (s EventsService) MarkPaymentRecovered(ctx context.Context, params EventCreateParams) (map[string]any, error) {
	params.Type = "payment_recovered"
	return s.Create(ctx, params)
}

type listResource struct {
	client *Client
	path   string
}

func (r listResource) list(ctx context.Context, params *ListParams) (map[string]any, error) {
	data, err := r.client.request(ctx, http.MethodGet, r.path, nil, params.values())
	if err != nil {
		return nil, err
	}
	var out map[string]any
	return out, json.Unmarshal(data, &out)
}

type CustomersService struct{ client *Client; path string }
func (s CustomersService) List(ctx context.Context, params *ListParams) (map[string]any, error) {
	return listResource{s.client, s.path}.list(ctx, params)
}

type RecoveriesService struct{ client *Client; path string }
func (s RecoveriesService) List(ctx context.Context, params *ListParams) (map[string]any, error) {
	return listResource{s.client, s.path}.list(ctx, params)
}
func (s RecoveriesService) MarkRecovered(ctx context.Context, recoveryAttemptID string) (map[string]any, error) {
	data, err := s.client.request(ctx, http.MethodPost, RecoveryMarkRecoveredPath(recoveryAttemptID), nil, nil)
	if err != nil {
		return nil, err
	}
	var out map[string]any
	return out, json.Unmarshal(data, &out)
}

type SequencesService struct{ client *Client; path string }
func (s SequencesService) List(ctx context.Context, params *ListParams) (map[string]any, error) {
	return listResource{s.client, s.path}.list(ctx, params)
}

type WebhooksService struct{ client *Client; path string }
func (s WebhooksService) List(ctx context.Context, params *ListParams) (map[string]any, error) {
	return listResource{s.client, s.path}.list(ctx, params)
}

type IncentivesService struct{ client *Client; path string }
func (s IncentivesService) List(ctx context.Context, params *ListParams) (map[string]any, error) {
	return listResource{s.client, s.path}.list(ctx, params)
}

type AnalyticsService struct{ client *Client; path string }
func (s AnalyticsService) Get(ctx context.Context, params *ListParams) (map[string]any, error) {
	return listResource{s.client, s.path}.list(ctx, params)
}

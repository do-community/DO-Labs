package main

import (
    "bytes"
    "flag"
    "fmt"
    "net/http"
    "sync"
    "time"
)

func main() {
    var (
        url         string
        concurrency int
        duration    int
    )

    flag.StringVar(&url, "url", "", "Target URL to send requests to")
    flag.IntVar(&concurrency, "c", 10, "Number of concurrent requests")
    flag.IntVar(&duration, "d", 30, "Duration to run the test in seconds")
    flag.Parse()

    if url == "" {
        fmt.Println("Please specify the target URL with -url")
        return
    }

    payload := []byte(`{
        "model": "meta/llama-3.1-8b-instruct",
        "prompt": "Write something long,",
        "max_tokens": 100,
        "temperature": 0.7,
        "top_p": 0.9,
        "n": 1,
        "stop": ["\n", "."]
    }`)

    var wg sync.WaitGroup
    stopChan := make(chan struct{})

    fmt.Printf("Running %d concurrent POST requests to %s for %d seconds...\n", concurrency, url, duration)

    client := &http.Client{}

    for i := 0; i < concurrency; i++ {
        wg.Add(1)
        go func(id int) {
            defer wg.Done()
            for {
                select {
                case <-stopChan:
                    return
                default:
                    req, err := http.NewRequest("POST", url, bytes.NewBuffer(payload))
                    if err != nil {
                        fmt.Printf("Request %d error creating request: %v\n", id, err)
                        time.Sleep(time.Second)
                        continue
                    }
                    req.Header.Set("Content-Type", "application/json")

                    resp, err := client.Do(req)
                    if err != nil {
                        fmt.Printf("Request %d error sending request: %v\n", id, err)
                        time.Sleep(time.Second)
                        continue
                    }
                    resp.Body.Close()
                }
            }
        }(i)
    }

    time.Sleep(time.Duration(duration) * time.Second)
    close(stopChan)
    wg.Wait()

    fmt.Println("Done.")
}

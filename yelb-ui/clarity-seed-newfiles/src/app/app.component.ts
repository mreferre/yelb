import { Component, OnInit, Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { environment } from '../environments/environment';
import { Headers, Http, Response } from '@angular/http';
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/map';

@Injectable()

@Component({
    selector: 'yelb',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss']
    })

export class AppComponent implements OnInit {
    constructor(private router: Router,
                private http:  Http
               ) {}

public appserver = environment.appserver_env;
colorScheme = {
    domain: ['#5AA454', '#A10A28', '#C7B42C', '#AAAAAA']
    };
votes: any[] = [];
stats: any;
hostname: any;
pageviews: any;
gradient: boolean;
view: any[] = [700, 200];
ngOnInit(){this.getvotes(); this.getstats()}

getvotes(): void {
    const url = `${this.appserver}/api/getvotes`;
    console.log("connecting to app server " + url);
    this.http.get(url)
                .map((res: Response) => res.json())
                .subscribe(res => {console.log(res); this.votes = res})                
    }

getstats(): void {
    const url = `${this.appserver}/api/getstats`;
    console.log("connecting to app server " + url);
    this.http.get(url)
                .map((res: Response) => res.json())
                .subscribe(res => {console.log(res, res.hostname, res.pageviews); this.stats = res})                
    }

vote(restaurant: string): void {
    const url = `${this.appserver}/api/${restaurant}`;
    console.log("connecting to app server " + url);
    this.http.get(url)
                .map((res: Response) => res.json())
                .subscribe(res => {console.log(res)});    
    this.getvotes()
    }
}

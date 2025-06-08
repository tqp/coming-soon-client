import {Routes} from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    loadComponent: () => import('./pages/coming-soon/coming-soon.component').then(c => c.ComingSoonComponent)
  },
  {
    path: 'coming-soon',
    loadComponent: () => import('./pages/coming-soon/coming-soon.component').then(c => c.ComingSoonComponent)
  },
  {
    path: '**',
    redirectTo: ''
  }
];
